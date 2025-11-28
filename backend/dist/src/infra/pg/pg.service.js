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
exports.PgService = void 0;
const common_1 = require("@nestjs/common");
const pg_1 = require("pg");
let PgService = class PgService {
    constructor() {
        var _a;
        const isProd = process.env.NODE_ENV === 'production';
        const dbName = (isProd ? process.env.PG_DATABASE || process.env.PG_DB : 'loco') || 'loco';
        const dbHost = isProd ? process.env.PG_HOST || 'localhost' : 'localhost';
        const dbPort = Number(process.env.PG_PORT) || 5432;
        const dbUser = isProd ? process.env.PG_USER || 'postgres' : 'postgres';
        const dbPassword = isProd ? process.env.PG_PASSWORD || 'postgres' : 'postgres';
        console.log('📦 PostgreSQL config:', {
            host: dbHost,
            port: dbPort,
            user: dbUser,
            database: dbName,
            env: (_a = process.env.NODE_ENV) !== null && _a !== void 0 ? _a : 'development',
        });
        this.client = new pg_1.Client({
            host: dbHost,
            port: dbPort,
            user: dbUser,
            password: dbPassword,
            database: dbName,
        });
    }
    async onModuleInit() {
        try {
            await this.client.connect();
            console.log('✅ Connected to PostgreSQL');
        }
        catch (err) {
            console.error('❌ Failed to connect to PostgreSQL:', err);
        }
    }
    async onModuleDestroy() {
        await this.client.end();
    }
    async query(sql, params) {
        return this.client.query(sql, params);
    }
};
exports.PgService = PgService;
exports.PgService = PgService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], PgService);
//# sourceMappingURL=pg.service.js.map