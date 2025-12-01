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
if (!process.env.SUPABASE_URL) {
    process.env.SUPABASE_URL = 'http://localhost';
    process.env.SUPABASE_KEY = 'dummy';
    console.warn('⚠️ Supabase dummy config injected (local dev)');
}
const isProd = process.env.NODE_ENV === 'production';
const tenantDbHost = isProd ? process.env.PG_HOST || 'localhost' : 'localhost';
const tenantDbPort = Number(process.env.PG_PORT || 5432);
const tenantDbName = isProd ? process.env.PG_DATABASE || 'loco' : 'loco';
const tenantDbUser = isProd ? process.env.PG_USER || 'postgres' : 'postgres';
const tenantDbPassword = isProd ? process.env.PG_PASSWORD || 'postgres' : 'postgres';
const tenantDbSsl = isProd && process.env.PG_SSL === 'true' ? { rejectUnauthorized: false } : undefined;
let TenantMiddleware = class TenantMiddleware {
    constructor() {
        this.pool = new pg_1.Pool({
            host: tenantDbHost,
            port: tenantDbPort,
            database: tenantDbName,
            user: tenantDbUser,
            password: tenantDbPassword,
            ssl: tenantDbSsl,
        });
    }
    async use(req, res, next) {
        if (!isProd) {
            return next();
        }
        const tenantCode = process.env.TENANT_CODE || 'cluj';
        try {
            req.db = await this.pool.connect();
            const checkTable = await req.db.query(`
        SELECT to_regclass('public.tenants') as exists;
      `);
            if (checkTable.rows[0].exists) {
                await req.db.query(`select set_config('app.tenant_id', (select id::text from tenants where code=$1 limit 1), true)`, [tenantCode]);
            }
            else {
                console.warn('⚠️ Tabela "tenants" nu există - continuăm fără filtrare multi-tenant.');
            }
            res.on('finish', () => req.db.release());
        }
        catch (err) {
            console.error('⚠️ Tenant middleware error:', err.message);
        }
        next();
    }
};
exports.TenantMiddleware = TenantMiddleware;
exports.TenantMiddleware = TenantMiddleware = __decorate([
    (0, common_1.Injectable)()
], TenantMiddleware);
//# sourceMappingURL=tenant.middleware.js.map