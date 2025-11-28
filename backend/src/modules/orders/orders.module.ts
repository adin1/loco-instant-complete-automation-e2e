import { Module } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';
import { InfraModule } from '../../infra/infra.module';

@Module({
  imports: [InfraModule],
  providers: [OrdersService],
  controllers: [OrdersController],
})
export class OrdersModule {}
