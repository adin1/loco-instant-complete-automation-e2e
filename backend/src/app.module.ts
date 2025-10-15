import { Module, MiddlewareConsumer } from '@nestjs/common';
import { PgService } from './infra/db/pg.service';
import { RedisService } from './infra/redis/redis.service';
import { OpenSearchService } from './infra/os/opensearch.service';
import { TenantMiddleware } from './common/middleware/tenant.middleware';
import { AuthModule } from './modules/auth/auth.module';
import { ProvidersModule } from './modules/providers/providers.module';
import { OrdersModule } from './modules/orders/orders.module';
import { SearchModule } from './modules/search/search.module';

@Module({
  imports: [AuthModule, ProvidersModule, OrdersModule, SearchModule],
  providers: [PgService, RedisService, OpenSearchService],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(TenantMiddleware).forRoutes('*');
  }
}