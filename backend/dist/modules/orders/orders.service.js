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
exports.OrdersService = void 0;
const common_1 = require("@nestjs/common");
const pg_service_1 = require("../../infra/db/pg.service");
let OrdersService = class OrdersService {
    constructor(pg) {
        this.pg = pg;
    }
    async getAll(q) {
        try {
            if (q && q.trim().length > 0) {
                const rows = await this.pg.query(`select o.*, p.status as payment_status, p.total_amount, p.auto_release_at
           from orders o
           left join payments p on p.order_id = o.id
           where (o.status ilike $1 or cast(o.id as text) = $2)
           order by o.id desc`, [`%${q}%`, q]);
                return rows;
            }
            const rows = await this.pg.query(`
        select o.*, p.status as payment_status, p.total_amount, p.auto_release_at
        from orders o
        left join payments p on p.order_id = o.id
        order by o.id desc
      `);
            return rows;
        }
        catch (err) {
            console.error('❌ Error fetching orders:', err);
            throw err;
        }
    }
    async getById(id) {
        const rows = await this.pg.query(`
      select o.*, 
        p.status as payment_status, 
        p.total_amount,
        p.advance_amount,
        p.remaining_amount,
        p.auto_release_at,
        EXTRACT(EPOCH FROM (p.auto_release_at - NOW())) / 3600 as hours_until_release,
        pr.display_name as provider_name,
        pr.rating_avg as provider_rating,
        uc.email as customer_email,
        s.name as service_name
      from orders o
      left join payments p on p.order_id = o.id
      left join providers pr on pr.id = o.provider_id
      left join users uc on uc.id = o.customer_id
      left join services s on s.id = o.service_id
      where o.id = $1
    `, [id]);
        if (rows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        const history = await this.pg.query(`
      select * from order_status_history
      where order_id = $1
      order by created_at asc
    `, [id]);
        const evidence = await this.pg.query(`
      select evidence_type, count(*) as count
      from order_evidence
      where order_id = $1
      group by evidence_type
    `, [id]);
        return {
            ...rows[0],
            statusHistory: history,
            evidenceSummary: evidence,
        };
    }
    async create(dto) {
        try {
            const { customerId, serviceId, providerId, status = 'pending', priceEstimate, currency, originLat, originLng, address, description, scheduledFor } = dto;
            const rows = await this.pg.query(`insert into orders (
           tenant_id, customer_id, service_id, provider_id, status, price_estimate, currency, origin_geom
         ) values (
           current_setting('app.tenant_id', true)::bigint, $1, $2, $3, $4, $5, coalesce($6, 'RON'), ST_SetSRID(ST_MakePoint($7, $8), 4326)::geography
         ) returning *`, [customerId, serviceId, providerId !== null && providerId !== void 0 ? providerId : null, status, priceEstimate !== null && priceEstimate !== void 0 ? priceEstimate : null, currency !== null && currency !== void 0 ? currency : null, originLng, originLat]);
            await this.logStatusChange(rows[0].id, null, status, customerId, 'customer');
            return rows[0];
        }
        catch (err) {
            console.error('❌ Error inserting order:', err);
            throw err;
        }
    }
    async update(id, dto) {
        const oldOrder = await this.getById(id);
        const oldStatus = oldOrder.status;
        const fields = [];
        const values = [];
        let idx = 1;
        if (dto.customerId !== undefined) {
            fields.push(`customer_id = $${idx++}`);
            values.push(dto.customerId);
        }
        if (dto.serviceId !== undefined) {
            fields.push(`service_id = $${idx++}`);
            values.push(dto.serviceId);
        }
        if (dto.providerId !== undefined) {
            fields.push(`provider_id = $${idx++}`);
            values.push(dto.providerId);
        }
        if (dto.status !== undefined) {
            fields.push(`status = $${idx++}`);
            values.push(dto.status);
        }
        if (dto.priceEstimate !== undefined) {
            fields.push(`price_estimate = $${idx++}`);
            values.push(dto.priceEstimate);
        }
        if (dto.currency !== undefined) {
            fields.push(`currency = $${idx++}`);
            values.push(dto.currency);
        }
        if (dto.originLat !== undefined && dto.originLng !== undefined) {
            fields.push(`origin_geom = ST_SetSRID(ST_MakePoint($${idx + 0}, $${idx + 1}), 4326)::geography`);
            values.push(dto.originLng, dto.originLat);
            idx += 2;
        }
        if (fields.length === 0) {
            return this.getById(id);
        }
        const query = `update orders set ${fields.join(', ')} where id = $${idx} returning *`;
        values.push(id);
        const rows = await this.pg.query(query, values);
        if (rows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        if (dto.status && dto.status !== oldStatus) {
            await this.logStatusChange(id, oldStatus, dto.status, null, 'system');
        }
        return rows[0];
    }
    async delete(id) {
        const rows = await this.pg.query('delete from orders where id = $1 returning id', [id]);
        if (rows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        return { success: true };
    }
    async markEnRoute(orderId, providerId) {
        const order = await this.getById(orderId);
        if (order.status !== 'assigned' && order.status !== 'funds_held') {
            throw new common_1.BadRequestException(`Cannot mark as en route from status: ${order.status}`);
        }
        await this.pg.query(`UPDATE orders SET status = 'provider_en_route' WHERE id = $1`, [orderId]);
        await this.logStatusChange(orderId, order.status, 'provider_en_route', providerId, 'provider');
        await this.sendSystemMessage(orderId, '🚗 Prestatorul este în drum către locație');
        return { success: true, status: 'provider_en_route' };
    }
    async startWork(orderId, providerId) {
        const order = await this.getById(orderId);
        if (order.status !== 'provider_en_route' && order.status !== 'funds_held') {
            throw new common_1.BadRequestException(`Cannot start work from status: ${order.status}`);
        }
        await this.pg.query(`UPDATE orders SET status = 'in_progress' WHERE id = $1`, [orderId]);
        await this.logStatusChange(orderId, order.status, 'in_progress', providerId, 'provider');
        await this.sendSystemMessage(orderId, '🔧 Prestatorul a început lucrarea');
        return { success: true, status: 'in_progress' };
    }
    async completeWork(orderId, providerId, dto) {
        const order = await this.getById(orderId);
        if (order.status !== 'in_progress') {
            throw new common_1.BadRequestException(`Cannot complete work from status: ${order.status}`);
        }
        const evidenceCheck = await this.pg.query(`
      SELECT evidence_type, COUNT(*) as count
      FROM order_evidence
      WHERE order_id = $1 AND evidence_type IN ('before_work', 'after_work')
      GROUP BY evidence_type
    `, [orderId]);
        const hasBeforePhotos = evidenceCheck.some((e) => e.evidence_type === 'before_work');
        const hasAfterPhotos = evidenceCheck.some((e) => e.evidence_type === 'after_work');
        if (!hasBeforePhotos || !hasAfterPhotos) {
            throw new common_1.BadRequestException('Trebuie să încarci poze înainte și după lucrare pentru a finaliza');
        }
        await this.pg.query(`UPDATE orders SET status = 'work_completed' WHERE id = $1`, [orderId]);
        const autoReleaseAt = new Date();
        autoReleaseAt.setHours(autoReleaseAt.getHours() + 48);
        await this.pg.query(`
      UPDATE payments 
      SET status = 'held', held_at = NOW(), auto_release_at = $1
      WHERE order_id = $2
    `, [autoReleaseAt.toISOString(), orderId]);
        await this.logStatusChange(orderId, order.status, 'work_completed', providerId, 'provider');
        await this.sendSystemMessage(orderId, `✅ Lucrarea a fost marcată ca finalizată de prestator.\n\n` +
            `📸 Au fost încărcate dovezi foto înainte/după.\n\n` +
            `⏰ Clientul are 48 ore să confirme lucrarea sau să raporteze o problemă.\n\n` +
            `Dacă nu se primește niciun răspuns, plata se va elibera automat.`);
        await this.pg.query(`
      INSERT INTO notifications (tenant_id, user_id, notification_type, title, body, data)
      SELECT tenant_id, customer_id, 'work_completed',
        'Lucrarea a fost finalizată',
        'Prestatorul a marcat lucrarea ca finalizată. Confirmă sau raportează o problemă în 48 ore.',
        $1
      FROM orders WHERE id = $2
    `, [JSON.stringify({ orderId }), orderId]);
        return {
            success: true,
            status: 'work_completed',
            autoReleaseAt,
            message: 'Lucrarea a fost marcată ca finalizată. Clientul are 48 ore să confirme.'
        };
    }
    async confirmWork(orderId, customerId, dto) {
        const order = await this.getById(orderId);
        if (order.status !== 'work_completed') {
            throw new common_1.BadRequestException(`Cannot confirm work from status: ${order.status}`);
        }
        if (order.customer_id !== customerId) {
            throw new common_1.BadRequestException('Only the customer can confirm this order');
        }
        await this.pg.query(`UPDATE orders SET status = 'confirmed' WHERE id = $1`, [orderId]);
        await this.pg.query(`
      UPDATE payments 
      SET status = 'released', released_at = NOW()
      WHERE order_id = $1
    `, [orderId]);
        await this.pg.query(`UPDATE orders SET status = 'completed' WHERE id = $1`, [orderId]);
        await this.logStatusChange(orderId, 'work_completed', 'completed', customerId, 'customer');
        await this.sendSystemMessage(orderId, '🎉 Clientul a confirmat lucrarea. Plata a fost eliberată către prestator.');
        if (dto === null || dto === void 0 ? void 0 : dto.rating) {
            await this.pg.query(`
        INSERT INTO user_ratings (
          tenant_id, order_id, rater_id, rated_id, rater_role, overall_rating, review_text
        ) SELECT 
          o.tenant_id, o.id, o.customer_id, pr.user_id, 'customer', $1, $2
        FROM orders o
        JOIN providers pr ON pr.id = o.provider_id
        WHERE o.id = $3
      `, [dto.rating, dto.feedback || null, orderId]);
        }
        return {
            success: true,
            status: 'completed',
            message: 'Lucrarea a fost confirmată și plata eliberată.'
        };
    }
    async getByStatus(status, customerId, providerId) {
        let query = `
      SELECT o.*, p.status as payment_status, p.auto_release_at
      FROM orders o
      LEFT JOIN payments p ON p.order_id = o.id
      WHERE o.status = $1
    `;
        const params = [status];
        if (customerId) {
            query += ` AND o.customer_id = $${params.length + 1}`;
            params.push(customerId);
        }
        if (providerId) {
            query += ` AND o.provider_id = $${params.length + 1}`;
            params.push(providerId);
        }
        query += ' ORDER BY o.created_at DESC';
        return this.pg.query(query, params);
    }
    async getTimeline(orderId) {
        const history = await this.pg.query(`
      SELECT h.*, u.email as changed_by_email
      FROM order_status_history h
      LEFT JOIN users u ON u.id = h.changed_by
      WHERE h.order_id = $1
      ORDER BY h.created_at ASC
    `, [orderId]);
        return history;
    }
    async logStatusChange(orderId, oldStatus, newStatus, changedBy, changedByRole) {
        await this.pg.query(`
      INSERT INTO order_status_history (
        tenant_id, order_id, old_status, new_status, changed_by, changed_by_role
      ) SELECT tenant_id, $1, $2, $3, $4, $5 FROM orders WHERE id = $1
    `, [orderId, oldStatus, newStatus, changedBy, changedByRole]);
    }
    async sendSystemMessage(orderId, content) {
        await this.pg.query(`
      INSERT INTO chat_messages (
        tenant_id, order_id, sender_id, sender_role, message_type, content
      ) SELECT tenant_id, $1, 0, 'system', 'status_update', $2
      FROM orders WHERE id = $1
    `, [orderId, content]);
    }
};
exports.OrdersService = OrdersService;
exports.OrdersService = OrdersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService])
], OrdersService);
//# sourceMappingURL=orders.service.js.map