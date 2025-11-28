import { Controller, Post, Body } from '@nestjs/common';
import { PaymentsService } from './payments.service';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('intent')
  async createIntent(@Body() body: any) {
    return this.paymentsService.createIntent(body);
  }

  @Post('confirm')
  async confirm(@Body() body: any) {
    return this.paymentsService.confirm(body);
  }
}


