"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentsService = void 0;
const common_1 = require("@nestjs/common");
const pg_service_1 = require("../../infra/db/pg.service");
let PaymentsService = class PaymentsService {
    constructor(pg) {
        this.pg = pg;
        this.AUTO_RELEASE_HOURS = 48;
        this.PLATFORM_FEE_PERCENT = 10;
        this.DEFAULT_ADVANCE_PERCENT = 30;
    }
    async createIntent(dto) {
        const { orderId, amount, currency = 'RON', isAdvanceOnly, advancePercentage = this.DEFAULT_ADVANCE_PERCENT } = dto;
        const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
        if (orderRows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        const order = orderRows[0];
        const advanceAmount = isAdvanceOnly ? Math.round(amount * advancePercentage / 100) : amount;
        const remainingAmount = amount - advanceAmount;
        const platformFee = Math.round(amount * this.PLATFORM_FEE_PERCENT / 100);
        const paymentRows = await this.pg.query(`INSERT INTO payments (
        tenant_id, order_id, customer_id, provider_id,
        total_amount, advance_amount, remaining_amount, platform_fee, currency,
        status
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, 'pending'
      ) RETURNING *`, [
            order.tenant_id,
            orderId,
            order.customer_id,
            order.provider_id,
            amount,
            advanceAmount,
            remainingAmount,
            platformFee,
            currency,
        ]);
        const payment = paymentRows[0];
        const mockPaymentIntentId = `pi_mock_${Date.now()}_${payment.id}`;
        await this.pg.query(`UPDATE payments SET stripe_payment_intent_id = $1 WHERE id = $2`, [mockPaymentIntentId, payment.id]);
        return {
            paymentId: payment.id,
            clientSecret: `${mockPaymentIntentId}_secret_mock`,
            amount: advanceAmount,
            totalAmount: amount,
            remainingAmount,
            currency,
            status: 'pending',
            isAdvanceOnly,
        };
    }
    async authorize(dto) {
        const { paymentId, stripePaymentMethodId } = dto;
        const paymentRows = await this.pg.query('SELECT * FROM payments WHERE id = $1', [paymentId]);
        if (paymentRows.length === 0) {
            throw new common_1.NotFoundException('Payment not found');
        }
        const payment = paymentRows[0];
        if (payment.status !== 'pending') {
            throw new common_1.BadRequestException(`Cannot authorize payment in status: ${payment.status}`);
        }
        await this.pg.query(`UPDATE payments 
       SET status = 'authorized', authorized_at = NOW() 
       WHERE id = $1`, [paymentId]);
        await this.pg.query(`UPDATE orders SET status = 'funds_held' WHERE id = $1`, [payment.order_id]);
        await this.logStatusChange(payment.order_id, 'pending', 'funds_held', null, 'system');
        return {
            success: true,
            paymentId,
            status: 'authorized',
            message: 'Fondurile au fost blocate pe card',
        };
    }
    async capture(dto) {
        const { paymentId, amount } = dto;
        const paymentRows = await this.pg.query('SELECT * FROM payments WHERE id = $1', [paymentId]);
        if (paymentRows.length === 0) {
            throw new common_1.NotFoundException('Payment not found');
        }
        const payment = paymentRows[0];
        if (!['authorized', 'advance_paid'].includes(payment.status)) {
            throw new common_1.BadRequestException(`Cannot capture payment in status: ${payment.status}`);
        }
        const captureAmount = amount !== null && amount !== void 0 ? amount : payment.advance_amount;
        const mockChargeId = `ch_mock_${Date.now()}_${paymentId}`;
        const newStatus = payment.remaining_amount > 0 ? 'advance_paid' : 'held';
        await this.pg.query(`UPDATE payments 
       SET status = $1, stripe_charge_id = $2, advance_paid_at = NOW(), held_at = NOW()
       WHERE id = $3`, [newStatus, mockChargeId, paymentId]);
        return {
            success: true,
            paymentId,
            status: newStatus,
            capturedAmount: captureAmount,
            message: 'Plata a fost procesată și fondurile sunt în escrow',
        };
    }
    async holdInEscrow(orderId, providerId) {
        const paymentRows = await this.pg.query('SELECT * FROM payments WHERE order_id = $1', [orderId]);
        if (paymentRows.length === 0) {
            throw new common_1.NotFoundException('Payment not found for order');
        }
        const payment = paymentRows[0];
        const autoReleaseAt = new Date();
        autoReleaseAt.setHours(autoReleaseAt.getHours() + this.AUTO_RELEASE_HOURS);
        await this.pg.query(`UPDATE payments 
       SET status = 'held', held_at = NOW(), auto_release_at = $1
       WHERE id = $2`, [autoReleaseAt.toISOString(), payment.id]);
        await this.pg.query(`INSERT INTO scheduled_tasks (
        tenant_id, task_type, reference_type, reference_id, scheduled_for, payload
      ) VALUES (
        $1, 'auto_release_payment', 'payment', $2, $3, $4
      )`, [
            payment.tenant_id,
            payment.id,
            autoReleaseAt.toISOString(),
            JSON.stringify({ orderId, providerId }),
        ]);
        return {
            success: true,
            paymentId: payment.id,
            autoReleaseAt,
            hoursUntilRelease: this.AUTO_RELEASE_HOURS,
        };
    }
    async releaseEscrow(dto) {
        const { paymentId, notes } = dto;
        const paymentRows = await this.pg.query('SELECT * FROM payments WHERE id = $1', [paymentId]);
        if (paymentRows.length === 0) {
            throw new common_1.NotFoundException('Payment not found');
        }
        const payment = paymentRows[0];
        if (payment.status !== 'held') {
            throw new common_1.BadRequestException(`Cannot release payment in status: ${payment.status}`);
        }
        const mockTransferId = `tr_mock_${Date.now()}_${paymentId}`;
        const providerAmount = payment.total_amount - payment.platform_fee;
        await this.pg.query(`UPDATE payments 
       SET status = 'released', released_at = NOW(), stripe_transfer_id = $1
       WHERE id = $2`, [mockTransferId, paymentId]);
        await this.pg.query(`UPDATE orders SET status = 'completed' WHERE id = $1`, [payment.order_id]);
        await this.pg.query(`UPDATE scheduled_tasks 
       SET status = 'cancelled' 
       WHERE reference_type = 'payment' AND reference_id = $1 AND status = 'pending'`, [paymentId]);
        await this.logStatusChange(payment.order_id, 'work_completed', 'completed', null, 'system');
        return {
            success: true,
            paymentId,
            status: 'released',
            providerAmount,
            platformFee: payment.platform_fee,
            message: 'Fondurile au fost transferate către prestator',
            notes,
        };
    }
    async refund(dto) {
        const { paymentId, amount, reason } = dto;
        const paymentRows = await this.pg.query('SELECT * FROM payments WHERE id = $1', [paymentId]);
        if (paymentRows.length === 0) {
            throw new common_1.NotFoundException('Payment not found');
        }
        const payment = paymentRows[0];
        if (!['held', 'advance_paid', 'fully_paid'].includes(payment.status)) {
            throw new common_1.BadRequestException(`Cannot refund payment in status: ${payment.status}`);
        }
        const refundAmount = amount !== null && amount !== void 0 ? amount : payment.total_amount;
        await this.pg.query(`UPDATE payments 
       SET status = 'refunded', refunded_at = NOW()
       WHERE id = $1`, [paymentId]);
        await this.pg.query(`UPDATE orders SET status = 'refunded' WHERE id = $1`, [payment.order_id]);
        await this.pg.query(`UPDATE scheduled_tasks 
       SET status = 'cancelled' 
       WHERE reference_type = 'payment' AND reference_id = $1 AND status = 'pending'`, [paymentId]);
        return {
            success: true,
            paymentId,
            status: 'refunded',
            refundedAmount: refundAmount,
            reason,
            message: 'Suma a fost rambursată către client',
        };
    }
    async getPaymentByOrderId(orderId) {
        const rows = await this.pg.query(`SELECT p.*, 
        EXTRACT(EPOCH FROM (p.auto_release_at - NOW())) / 3600 as hours_until_release,
        o.status as order_status
       FROM payments p
       JOIN orders o ON o.id = p.order_id
       WHERE p.order_id = $1`, [orderId]);
        if (rows.length === 0) {
            return null;
        }
        return rows[0];
    }
    async getAllPayments(filters) {
        let query = 'SELECT * FROM payments WHERE 1=1';
        const params = [];
        let paramIndex = 1;
        if (filters === null || filters === void 0 ? void 0 : filters.status) {
            query += ` AND status = $${paramIndex++}`;
            params.push(filters.status);
        }
        if (filters === null || filters === void 0 ? void 0 : filters.orderId) {
            query += ` AND order_id = $${paramIndex++}`;
            params.push(filters.orderId);
        }
        query += ' ORDER BY created_at DESC';
        return this.pg.query(query, params);
    }
    async processAutoRelease() {
        const pendingTasks = await this.pg.query(`SELECT st.*, p.id as payment_id, p.status as payment_status
       FROM scheduled_tasks st
       JOIN payments p ON p.id = st.reference_id
       WHERE st.task_type = 'auto_release_payment'
         AND st.status = 'pending'
         AND st.scheduled_for <= NOW()
         AND p.status = 'held'`);
        const results = [];
        for (const task of pendingTasks) {
            try {
                await this.releaseEscrow({ paymentId: task.payment_id });
                await this.pg.query(`UPDATE scheduled_tasks 
           SET status = 'executed', executed_at = NOW(), result = $1
           WHERE id = $2`, [JSON.stringify({ success: true }), task.id]);
                results.push({ taskId: task.id, success: true });
            }
            catch (error) {
                await this.pg.query(`UPDATE scheduled_tasks 
           SET status = 'failed', result = $1
           WHERE id = $2`, [JSON.stringify({ error: error.message }), task.id]);
                results.push({ taskId: task.id, success: false, error: error.message });
            }
        }
        return { processed: results.length, results };
    }
    async logStatusChange(orderId, oldStatus, newStatus, changedBy, changedByRole) {
        await this.pg.query(`INSERT INTO order_status_history (
        tenant_id, order_id, old_status, new_status, changed_by, changed_by_role
      ) SELECT tenant_id, $1, $2, $3, $4, $5 FROM orders WHERE id = $1`, [orderId, oldStatus, newStatus, changedBy, changedByRole]);
    }
    async createPaymentIntent(body) {
        var _a, _b;
        return this.createIntent({
            orderId: body.orderId,
            amount: (_a = body.amount) !== null && _a !== void 0 ? _a : 100,
            currency: (_b = body.currency) !== null && _b !== void 0 ? _b : 'RON',
        });
    }
    async confirm(body) {
        var _a, _b;
        if (body.paymentId) {
            return this.authorize({
                paymentId: parseInt(body.paymentId, 10),
                stripePaymentMethodId: (_a = body.paymentMethodId) !== null && _a !== void 0 ? _a : 'mock_pm',
            });
        }
        return { success: true, paymentId: (_b = body.paymentId) !== null && _b !== void 0 ? _b : 'mock_payment_id' };
    }
};
exports.PaymentsService = PaymentsService;
exports.PaymentsService = PaymentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService])
], PaymentsService);
//# sourceMappingURL=payments.service.js.map