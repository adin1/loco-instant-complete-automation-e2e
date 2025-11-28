import { Module } from '@nestjs/common';
import { PgService } from './db/pg.service';
import { RedisService } from './redis/redis.service';
import { OpenSearchService } from './os/opensearch.service';

@Module({
  providers: [PgService, RedisService, OpenSearchService],
  exports: [PgService, RedisService, OpenSearchService],
})
export class InfraModule {}
