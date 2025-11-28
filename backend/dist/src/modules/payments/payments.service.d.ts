export declare class PaymentsService {
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
