import { Injectable } from '@nestjs/common';
import { PgService } from '../../infra/db/pg.service';
import { RedisService } from '../../infra/redis/redis.service';

@Injectable()
export class ProvidersService {
  constructor(private pg: PgService, private redis: RedisService) {}
  async listAll() { return this.pg.query('select * from providers order by id desc'); }
  async findNearby(lat: number, lon: number, radiusMeters: number) {
    if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
      throw new Error('Invalid coordinates');
    }
    const rows = await this.pg.query(
      `
      select p.*, l.address,
             ST_Distance(l.geom, ST_MakePoint($1, $2)::geography) as distance_m
      from providers p
      join locations l
        on l.owner_type = 'provider'
       and l.owner_id = p.id
      where ST_DWithin(l.geom, ST_MakePoint($1, $2)::geography, $3)
      order by distance_m asc
      limit 100
      `,
      [lon, lat, radiusMeters],
    );
    return rows;
  }
  async getOne(id: number) { return (await this.pg.query('select * from providers where id=$1', [id]))[0]; }
  async getStatus(id: number) { return this.redis.client.get(`provider:${id}:status`); }
  async setStatus(id: number, status: string) { await this.redis.client.set(`provider:${id}:status`, status, { EX: 300 });
 return { id, status }; }
}