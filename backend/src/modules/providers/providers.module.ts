import { Module } from '@nestjs/common';
import { ProvidersService } from './providers.service';
import { ProvidersController } from './providers.controller';
import { PgService } from '../../infra/db/pg.service';
import { RedisService } from '../../infra/redis/redis.service';

@Module({
  providers: [ProvidersService, PgService, RedisService],
  exports: [ProvidersService],
  controllers: [ProvidersController],
})
export class ProvidersModule {}
