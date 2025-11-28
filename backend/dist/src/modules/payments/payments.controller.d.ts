import { PaymentsService } from './payments.service';
export declare class PaymentsController {
    private readonly paymentsService;
    constructor(paymentsService: PaymentsService);
    createIntent(body: any): Promise<{
        clientSecret: string;
        amount: any;
        currency: any;
    }>;
    confirm(body: any): Promise<{
        success: boolean;
        paymentId: any;
    }>;
}
