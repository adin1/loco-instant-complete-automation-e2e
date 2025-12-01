import { PgService } from '../../infra/db/pg.service';
import { RedisService } from '../../infra/redis/redis.service';
export declare class ProvidersService {
    private pg;
    private redis;
    constructor(pg: PgService, redis: RedisService);
    listAll(): Promise<any>;
    findNearby(lat: number, lon: number, radiusMeters: number): Promise<any>;
    getOne(id: number): Promise<any>;
    getStatus(id: number): Promise<string>;
    setStatus(id: number, status: string): Promise<{
        id: number;
        status: string;
    }>;
}
