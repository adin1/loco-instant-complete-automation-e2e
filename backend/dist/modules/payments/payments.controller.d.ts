import { PaymentsService } from './payments.service';
import { CreatePaymentIntentDto, AuthorizePaymentDto, CapturePaymentDto, ReleaseEscrowDto, RefundPaymentDto } from './dto/payment.dto';
export declare class PaymentsController {
    private readonly paymentsService;
    constructor(paymentsService: PaymentsService);
    createIntent(body: CreatePaymentIntentDto): Promise<{
        paymentId: any;
        clientSecret: string;
        amount: number;
        totalAmount: number;
        remainingAmount: number;
        currency: string;
        status: string;
        isAdvanceOnly: boolean;
    }>;
    authorize(body: AuthorizePaymentDto): Promise<{
        success: boolean;
        paymentId: number;
        status: string;
        message: string;
    }>;
    capture(body: CapturePaymentDto): Promise<{
        success: boolean;
        paymentId: number;
        status: string;
        capturedAmount: any;
        message: string;
    }>;
    releaseEscrow(body: ReleaseEscrowDto): Promise<{
        success: boolean;
        paymentId: number;
        status: string;
        providerAmount: number;
        platformFee: any;
        message: string;
        notes: string;
    }>;
    refund(body: RefundPaymentDto): Promise<{
        success: boolean;
        paymentId: number;
        status: string;
        refundedAmount: any;
        reason: string;
        message: string;
    }>;
    getByOrderId(orderId: number): Promise<any>;
    getAll(status?: string, orderId?: string): Promise<any>;
    processAutoRelease(): Promise<{
        processed: number;
        results: any[];
    }>;
    confirm(body: any): Promise<{
        success: boolean;
        paymentId: number;
        status: string;
        message: string;
    } | {
        success: boolean;
        paymentId: any;
    }>;
}
