import { OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { RedisClientType } from 'redis';
export declare class RedisService implements OnModuleInit, OnModuleDestroy {
    client: RedisClientType;
    constructor();
    onModuleInit(): Promise<void>;
    onModuleDestroy(): Promise<void>;
}
