import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { createClient, RedisClientType } from 'redis';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  public client: RedisClientType;

  constructor() {
    const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
    this.client = createClient({ url: redisUrl });
  }

  async onModuleInit() {
    try {
      await this.client.connect();
      console.log('✅ Connected to Redis');
    } catch (err) {
      // Don't crash the app if Redis is not available locally.
      // We just log a concise warning and continue in degraded mode.
      const message =
        err instanceof Error ? err.message : 'Unknown Redis connection error';
      console.warn(
        `❌ Failed to connect to Redis (running without Redis). Details: ${message}`,
      );
    }
  }

  async onModuleDestroy() {
    await this.client.quit();
  }
}
