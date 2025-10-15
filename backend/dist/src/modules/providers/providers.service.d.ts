import { PgService } from '../../infra/db/pg.service';
import { RedisService } from '../../infra/redis/redis.service';
export declare class ProvidersService {
    private pg;
    private redis;
    constructor(pg: PgService, redis: RedisService);
    getOne(id: number): Promise<any>;
    getStatus(id: number): Promise<string>;
    setStatus(id: number, status: string): Promise<{
        id: number;
        status: string;
    }>;
}
