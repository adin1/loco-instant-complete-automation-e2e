import { OnModuleInit, OnModuleDestroy } from '@nestjs/common';
export declare class PgService implements OnModuleInit, OnModuleDestroy {
    private client;
    constructor();
    onModuleInit(): Promise<void>;
    onModuleDestroy(): Promise<void>;
    query(sql: string, params?: any[]): Promise<any>;
}
