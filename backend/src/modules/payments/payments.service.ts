import { Injectable } from '@nestjs/common';

@Injectable()
export class PaymentsService {
  async createIntent(body: any) {
    // TODO: Integrate Stripe or payments provider.
    return {
      clientSecret: 'mock_client_secret',
      amount: body.amount ?? 0,
      currency: body.currency ?? 'EUR',
    };
  }

  async confirm(body: any) {
    return {
      success: true,
      paymentId: body.paymentId ?? 'mock_payment_id',
    };
  }
}


