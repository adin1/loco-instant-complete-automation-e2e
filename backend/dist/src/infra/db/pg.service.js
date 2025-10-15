"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PgService = void 0;
const common_1 = require("@nestjs/common");
const pg_1 = require("pg");
let PgService = class PgService {
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
    async query(text, params) {
        const client = await this.pool.connect();
        try {
            const res = await client.query(text, params);
            return res.rows;
        }
        finally {
            client.release();
        }
    }
};
exports.PgService = PgService;
exports.PgService = PgService = __decorate([
    (0, common_1.Injectable)()
], PgService);
//# sourceMappingURL=pg.service.js.map