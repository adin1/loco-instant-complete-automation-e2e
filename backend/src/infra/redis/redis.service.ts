import { Injectable, OnModuleInit } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit {
  public client!: Redis;
  onModuleInit() {
    this.client = new Redis(process.env.REDIS_URL!);
  }
}