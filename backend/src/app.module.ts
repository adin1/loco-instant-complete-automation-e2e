import { Module, MiddlewareConsumer } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { PgService } from './infra/db/pg.service';
import { RedisService } from './infra/redis/redis.service';
// import { OpenSearchService } from './infra/os/opensearch.service';
import { TenantMiddleware } from './common/middleware/tenant.middleware';
import { AuthModule } from './modules/auth/auth.module';
import { ProvidersModule } from './modules/providers/providers.module';
import { OrdersModule } from './modules/orders/orders.module';
import { SearchModule } from './modules/search/search.module';
import { OpensearchModule } from './modules/opensearch/opensearch.module';
import { UsersModule } from './modules/users/users.module';
import { RequestsModule } from './modules/requests/requests.module';
import { OffersModule } from './modules/offers/offers.module';
import { ChatModule } from './modules/chat/chat.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { ReviewsModule } from './modules/reviews/reviews.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { RealtimeModule } from './modules/realtime/realtime.module';
import { EvidenceModule } from './modules/evidence/evidence.module';
import { DisputesModule } from './modules/disputes/disputes.module';
import { HealthController } from './health.controller';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    AuthModule,
    ProvidersModule,
    OrdersModule,
    SearchModule,
    OpensearchModule,
    UsersModule,
    RequestsModule,
    OffersModule,
    ChatModule,
    PaymentsModule,
    ReviewsModule,
    NotificationsModule,
    RealtimeModule,
    EvidenceModule,
    DisputesModule,
  ],
  providers: [PgService, RedisService],
  controllers: [HealthController],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(TenantMiddleware).forRoutes('*');
  }
}