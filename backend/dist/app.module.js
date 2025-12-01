"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const schedule_1 = require("@nestjs/schedule");
const pg_service_1 = require("./infra/db/pg.service");
const redis_service_1 = require("./infra/redis/redis.service");
const tenant_middleware_1 = require("./common/middleware/tenant.middleware");
const auth_module_1 = require("./modules/auth/auth.module");
const providers_module_1 = require("./modules/providers/providers.module");
const orders_module_1 = require("./modules/orders/orders.module");
const search_module_1 = require("./modules/search/search.module");
const opensearch_module_1 = require("./modules/opensearch/opensearch.module");
const users_module_1 = require("./modules/users/users.module");
const requests_module_1 = require("./modules/requests/requests.module");
const offers_module_1 = require("./modules/offers/offers.module");
const chat_module_1 = require("./modules/chat/chat.module");
const payments_module_1 = require("./modules/payments/payments.module");
const reviews_module_1 = require("./modules/reviews/reviews.module");
const notifications_module_1 = require("./modules/notifications/notifications.module");
const realtime_module_1 = require("./modules/realtime/realtime.module");
const evidence_module_1 = require("./modules/evidence/evidence.module");
const disputes_module_1 = require("./modules/disputes/disputes.module");
const health_controller_1 = require("./health.controller");
let AppModule = class AppModule {
    configure(consumer) {
        consumer.apply(tenant_middleware_1.TenantMiddleware).forRoutes('*');
    }
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            schedule_1.ScheduleModule.forRoot(),
            auth_module_1.AuthModule,
            providers_module_1.ProvidersModule,
            orders_module_1.OrdersModule,
            search_module_1.SearchModule,
            opensearch_module_1.OpensearchModule,
            users_module_1.UsersModule,
            requests_module_1.RequestsModule,
            offers_module_1.OffersModule,
            chat_module_1.ChatModule,
            payments_module_1.PaymentsModule,
            reviews_module_1.ReviewsModule,
            notifications_module_1.NotificationsModule,
            realtime_module_1.RealtimeModule,
            evidence_module_1.EvidenceModule,
            disputes_module_1.DisputesModule,
        ],
        providers: [pg_service_1.PgService, redis_service_1.RedisService],
        controllers: [health_controller_1.HealthController],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map