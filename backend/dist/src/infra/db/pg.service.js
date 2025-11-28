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
        this.client = new pg_1.Client({
            host: process.env.PG_HOST || 'localhost',
            port: Number(process.env.PG_PORT) || 5432,
            user: process.env.PG_USER || 'postgres',
            password: process.env.PG_PASSWORD || 'postgres',
            database: process.env.PG_DATABASE || 'loco',
        });
    }
    async onModuleInit() {
        try {
            await this.client.connect();
            console.log('✅ Connected to PostgreSQL');
        }
        catch (err) {
            const message = err instanceof Error ? err.message : 'Unknown PostgreSQL connection error';
            console.warn(`❌ Failed to connect to PostgreSQL (running without DB). Details: ${message}`);
        }
    }
    async onModuleDestroy() {
        await this.client.end();
    }
    async query(sql, params) {
        const res = await this.client.query(sql, params);
        return res.rows;
    }
};
exports.PgService = PgService;
exports.PgService = PgService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], PgService);
//# sourceMappingURL=pg.service.js.map