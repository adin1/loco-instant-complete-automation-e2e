import { Injectable } from '@nestjs/common';
import { PgService } from '../../infra/db/pg.service';
import { RedisService } from '../../infra/redis/redis.service';

@Injectable()
export class ProvidersService {
  constructor(private pg: PgService, private redis: RedisService) {}
  async getOne(id: number) { return (await this.pg.query('select * from providers where id=$1', [id]))[0]; }
  async getStatus(id: number) { return this.redis.client.get(`provider:${id}:status`); }
  async setStatus(id: number, status: string) { await this.redis.client.set(`provider:${id}:status`, status, 'EX', 300); return { id, status }; }
}