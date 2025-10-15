import { OnModuleInit } from '@nestjs/common';
import Redis from 'ioredis';
export declare class RedisService implements OnModuleInit {
    client: Redis;
    onModuleInit(): void;
}
