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
exports.DisputesService = void 0;
const common_1 = require("@nestjs/common");
const pg_service_1 = require("../../infra/db/pg.service");
let DisputesService = class DisputesService {
    constructor(pg) {
        this.pg = pg;
    }
    async create(dto, filedBy, filedByRole) {
        const { orderId, category, title, description, whatNotWorking, technicalDetails, evidenceUrls } = dto;
        const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
        if (orderRows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        const order = orderRows[0];
        if (!['work_completed', 'confirmed', 'funds_held'].includes(order.status)) {
            throw new common_1.BadRequestException(`Cannot create dispute for order in status: ${order.status}`);
        }
        if (filedByRole === 'customer' && order.customer_id !== filedBy) {
            throw new common_1.ForbiddenException('You are not the customer for this order');
        }
        const paymentRows = await this.pg.query('SELECT * FROM payments WHERE order_id = $1', [orderId]);
        const payment = paymentRows[0];
        const disputeRows = await this.pg.query(`INSERT INTO disputes (
        tenant_id, order_id, payment_id, filed_by, filed_by_role,
        category, title, description, what_not_working, technical_details, status
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'open'
      ) RETURNING *`, [
            order.tenant_id,
            orderId,
            payment === null || payment === void 0 ? void 0 : payment.id,
            filedBy,
            filedByRole,
            category,
            title,
            description,
            whatNotWorking,
            technicalDetails,
        ]);
        const dispute = disputeRows[0];
        await this.pg.query(`UPDATE orders SET status = 'disputed' WHERE id = $1`, [orderId]);
        if (payment) {
            await this.pg.query(`UPDATE payments SET status = 'disputed' WHERE id = $1`, [payment.id]);
        }
        if (evidenceUrls && evidenceUrls.length > 0) {
            for (const url of evidenceUrls) {
                await this.pg.query(`INSERT INTO order_evidence (
            tenant_id, order_id, uploaded_by, evidence_type, media_type, file_url
          ) VALUES (
            $1, $2, $3, 'dispute_evidence', 'image', $4
          )`, [order.tenant_id, orderId, filedBy, url]);
            }
        }
        await this.sendDisputeNotification(order, dispute, filedByRole);
        return dispute;
    }
    async getById(disputeId) {
        const rows = await this.pg.query(`SELECT d.*, 
        o.status as order_status,
        p.total_amount, p.status as payment_status,
        uc.email as customer_email,
        pr.display_name as provider_name
       FROM disputes d
       JOIN orders o ON o.id = d.order_id
       LEFT JOIN payments p ON p.id = d.payment_id
       JOIN users uc ON uc.id = o.customer_id
       LEFT JOIN providers pr ON pr.id = o.provider_id
       WHERE d.id = $1`, [disputeId]);
        if (rows.length === 0) {
            throw new common_1.NotFoundException('Dispute not found');
        }
        const evidence = await this.pg.query(`SELECT * FROM order_evidence WHERE order_id = $1 ORDER BY created_at`, [rows[0].order_id]);
        return {
            ...rows[0],
            evidence,
        };
    }
    async getByOrderId(orderId) {
        const rows = await this.pg.query(`SELECT * FROM disputes WHERE order_id = $1 ORDER BY created_at DESC`, [orderId]);
        return rows;
    }
    async getAll(filters) {
        let query = `
      SELECT d.*, 
        o.status as order_status,
        uc.email as customer_email,
        pr.display_name as provider_name
      FROM disputes d
      JOIN orders o ON o.id = d.order_id
      JOIN users uc ON uc.id = o.customer_id
      LEFT JOIN providers pr ON pr.id = o.provider_id
      WHERE 1=1
    `;
        const params = [];
        let paramIndex = 1;
        if (filters === null || filters === void 0 ? void 0 : filters.status) {
            query += ` AND d.status = $${paramIndex++}`;
            params.push(filters.status);
        }
        if (filters === null || filters === void 0 ? void 0 : filters.category) {
            query += ` AND d.category = $${paramIndex++}`;
            params.push(filters.category);
        }
        query += ' ORDER BY d.created_at DESC';
        return this.pg.query(query, params);
    }
    async providerResponse(dto, providerId) {
        const { disputeId, response, evidenceUrls, acceptRevisit } = dto;
        const dispute = await this.getById(disputeId);
        await this.pg.query(`UPDATE disputes 
       SET status = $1, updated_at = NOW()
       WHERE id = $2`, [acceptRevisit ? 'scheduled_revisit' : 'awaiting_response', disputeId]);
        if (evidenceUrls && evidenceUrls.length > 0) {
            const providerUserId = await this.getProviderUserId(providerId);
            for (const url of evidenceUrls) {
                await this.pg.query(`INSERT INTO order_evidence (
            tenant_id, order_id, uploaded_by, evidence_type, media_type, file_url, description
          ) VALUES (
            $1, $2, $3, 'dispute_evidence', 'image', $4, $5
          )`, [dispute.tenant_id, dispute.order_id, providerUserId, url, `Provider response: ${response.substring(0, 100)}`]);
            }
        }
        return { success: true, message: 'Response submitted' };
    }
    async scheduleRevisit(dto) {
        const { disputeId, scheduledAt, cost = 0, notes } = dto;
        await this.pg.query(`UPDATE disputes 
       SET status = 'scheduled_revisit', 
           revisit_scheduled_at = $1,
           revisit_cost = $2,
           revisit_notes = $3,
           updated_at = NOW()
       WHERE id = $4`, [scheduledAt, cost, notes, disputeId]);
        return { success: true, message: 'Revisit scheduled' };
    }
    async resolve(dto, resolvedBy) {
        const { disputeId, resolution, refundAmount, resolutionNotes } = dto;
        const dispute = await this.getById(disputeId);
        await this.pg.query(`UPDATE disputes 
       SET status = $1, 
           resolution_notes = $2,
           resolution_amount = $3,
           resolved_by = $4,
           resolved_at = NOW(),
           updated_at = NOW()
       WHERE id = $5`, [resolution, resolutionNotes, refundAmount, resolvedBy, disputeId]);
        if (dispute.payment_id) {
            switch (resolution) {
                case 'resolved_refund':
                    await this.pg.query(`UPDATE payments SET status = 'refunded', refunded_at = NOW() WHERE id = $1`, [dispute.payment_id]);
                    await this.pg.query(`UPDATE orders SET status = 'refunded' WHERE id = $1`, [dispute.order_id]);
                    break;
                case 'resolved_partial':
                    break;
                case 'resolved_redo':
                    await this.pg.query(`UPDATE orders SET status = 'in_progress' WHERE id = $1`, [dispute.order_id]);
                    break;
                case 'rejected':
                    await this.pg.query(`UPDATE payments SET status = 'released', released_at = NOW() WHERE id = $1`, [dispute.payment_id]);
                    await this.pg.query(`UPDATE orders SET status = 'completed' WHERE id = $1`, [dispute.order_id]);
                    break;
            }
        }
        return { success: true, message: `Dispute resolved as: ${resolution}` };
    }
    async getStats() {
        const stats = await this.pg.query(`
      SELECT 
        status,
        category,
        COUNT(*) as count
      FROM disputes
      GROUP BY status, category
    `);
        const byStatus = {};
        const byCategory = {};
        for (const row of stats) {
            byStatus[row.status] = (byStatus[row.status] || 0) + parseInt(row.count);
            byCategory[row.category] = (byCategory[row.category] || 0) + parseInt(row.count);
        }
        return { byStatus, byCategory };
    }
    async getProviderUserId(providerId) {
        var _a;
        const rows = await this.pg.query('SELECT user_id FROM providers WHERE id = $1', [providerId]);
        return (_a = rows[0]) === null || _a === void 0 ? void 0 : _a.user_id;
    }
    async sendDisputeNotification(order, dispute, filedByRole) {
        const notifyUserId = filedByRole === 'customer'
            ? await this.getProviderUserId(order.provider_id)
            : order.customer_id;
        if (notifyUserId) {
            await this.pg.query(`INSERT INTO notifications (
          tenant_id, user_id, notification_type, title, body, data
        ) VALUES (
          $1, $2, 'dispute_opened', $3, $4, $5
        )`, [
                order.tenant_id,
                notifyUserId,
                'Reclamație nouă',
                `O reclamație a fost deschisă pentru comanda #${order.id}: ${dispute.title}`,
                JSON.stringify({ orderId: order.id, disputeId: dispute.id }),
            ]);
        }
    }
};
exports.DisputesService = DisputesService;
exports.DisputesService = DisputesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService])
], DisputesService);
//# sourceMappingURL=disputes.service.js.map