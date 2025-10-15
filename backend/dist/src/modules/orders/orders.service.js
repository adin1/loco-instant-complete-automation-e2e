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
    async create(b) {
        const { customer_id, service_id, origin_lat, origin_lon, price_estimate } = b;
        const rows = await this.pg.query(`insert into orders(tenant_id, customer_id, service_id, status, origin_geom, price_estimate)
       values ((select id from tenants where code=$1), $2, $3, 'pending', ST_SetSRID(ST_MakePoint($4,$5),4326)::geography, $6)
       returning id`, [process.env.TENANT_CODE || 'cluj', customer_id, service_id, origin_lon, origin_lat, price_estimate]);
        const orderId = rows[0].id;
        await this.pg.query(`insert into order_events(tenant_id, order_id, event_type, payload)
       values ((select id from tenants where code=$1), $2, 'order_created', jsonb_build_object('order_id',$2))`, [process.env.TENANT_CODE || 'cluj', orderId]);
        return { id: orderId };
    }
};
exports.OrdersService = OrdersService;
exports.OrdersService = OrdersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService])
], OrdersService);
//# sourceMappingURL=orders.service.js.map