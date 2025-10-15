"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TenantMiddleware = void 0;
const common_1 = require("@nestjs/common");
const pg_1 = require("pg");
let TenantMiddleware = class TenantMiddleware {
    constructor() {
        this.pool = new pg_1.Pool({
            host: process.env.PG_HOST,
            port: Number(process.env.PG_PORT || 5432),
            database: process.env.PG_DATABASE,
            user: process.env.PG_USER,
            password: process.env.PG_PASSWORD,
            ssl: process.env.PG_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
        });
    }
    async use(req, res, next) {
        const tenantCode = process.env.TENANT_CODE || 'cluj';
        req.db = await this.pool.connect();
        await req.db.query(`select set_config('app.tenant_id', (select id::text from tenants where code=$1), true)`, [tenantCode]);
        res.on('finish', () => req.db.release());
        next();
    }
};
exports.TenantMiddleware = TenantMiddleware;
exports.TenantMiddleware = TenantMiddleware = __decorate([
    (0, common_1.Injectable)()
], TenantMiddleware);
//# sourceMappingURL=tenant.middleware.js.map