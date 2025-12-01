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
exports.ProvidersService = void 0;
const common_1 = require("@nestjs/common");
const pg_service_1 = require("../../infra/db/pg.service");
const redis_service_1 = require("../../infra/redis/redis.service");
let ProvidersService = class ProvidersService {
    constructor(pg, redis) {
        this.pg = pg;
        this.redis = redis;
    }
    async listAll() { return this.pg.query('select * from providers order by id desc'); }
    async findNearby(lat, lon, radiusMeters) {
        if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
            throw new Error('Invalid coordinates');
        }
        const rows = await this.pg.query(`
      select p.*, l.address,
             ST_Distance(l.geom, ST_MakePoint($1, $2)::geography) as distance_m
      from providers p
      join locations l
        on l.owner_type = 'provider'
       and l.owner_id = p.id
      where ST_DWithin(l.geom, ST_MakePoint($1, $2)::geography, $3)
      order by distance_m asc
      limit 100
      `, [lon, lat, radiusMeters]);
        return rows;
    }
    async getOne(id) { return (await this.pg.query('select * from providers where id=$1', [id]))[0]; }
    async getStatus(id) { return this.redis.client.get(`provider:${id}:status`); }
    async setStatus(id, status) {
        await this.redis.client.set(`provider:${id}:status`, status, { EX: 300 });
        return { id, status };
    }
};
exports.ProvidersService = ProvidersService;
exports.ProvidersService = ProvidersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService, redis_service_1.RedisService])
], ProvidersService);
//# sourceMappingURL=providers.service.js.map