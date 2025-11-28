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
                const rows = await this.pg.query(`select * from orders
           where (status ilike $1 or cast(id as text) = $2)
           order by id desc`, [`%${q}%`, q]);
                return rows;
            }
            const rows = await this.pg.query('select * from orders order by id desc');
            return rows;
        }
        catch (err) {
            console.error('❌ Error fetching orders:', err);
            throw err;
        }
    }
    async getById(id) {
        const rows = await this.pg.query('select * from orders where id = $1', [id]);
        if (rows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        return rows[0];
    }
    async create(dto) {
        try {
            const { customerId, serviceId, providerId, status, priceEstimate, currency, originLat, originLng } = dto;
            const rows = await this.pg.query(`insert into orders (
           tenant_id, customer_id, service_id, provider_id, status, price_estimate, currency, origin_geom
         ) values (
           current_setting('app.tenant_id', true)::bigint, $1, $2, $3, $4, $5, coalesce($6, 'RON'), ST_SetSRID(ST_MakePoint($7, $8), 4326)::geography
         ) returning *`, [customerId, serviceId, providerId !== null && providerId !== void 0 ? providerId : null, status, priceEstimate !== null && priceEstimate !== void 0 ? priceEstimate : null, currency !== null && currency !== void 0 ? currency : null, originLng, originLat]);
            return rows[0];
        }
        catch (err) {
            console.error('❌ Error inserting order:', err);
            throw err;
        }
    }
    async update(id, dto) {
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
        return rows[0];
    }
    async delete(id) {
        const rows = await this.pg.query('delete from orders where id = $1 returning id', [id]);
        if (rows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        return { success: true };
    }
};
exports.OrdersService = OrdersService;
exports.OrdersService = OrdersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService])
], OrdersService);
//# sourceMappingURL=orders.service.js.map