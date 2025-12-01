import { PgService } from '../../infra/db/pg.service';
import { CreatePaymentIntentDto, AuthorizePaymentDto, CapturePaymentDto, ReleaseEscrowDto, RefundPaymentDto } from './dto/payment.dto';
export declare class PaymentsService {
    private pg;
    private readonly AUTO_RELEASE_HOURS;
    private readonly PLATFORM_FEE_PERCENT;
    private readonly DEFAULT_ADVANCE_PERCENT;
    constructor(pg: PgService);
    createIntent(dto: CreatePaymentIntentDto): Promise<{
        paymentId: any;
        clientSecret: string;
        amount: number;
        totalAmount: number;
        remainingAmount: number;
        currency: string;
        status: string;
        isAdvanceOnly: boolean;
    }>;
    authorize(dto: AuthorizePaymentDto): Promise<{
        success: boolean;
        paymentId: number;
        status: string;
        message: string;
    }>;
    capture(dto: CapturePaymentDto): Promise<{
        success: boolean;
        paymentId: number;
        status: string;
        capturedAmount: any;
        message: string;
    }>;
    holdInEscrow(orderId: number, providerId: number): Promise<{
        success: boolean;
        paymentId: any;
        autoReleaseAt: Date;
        hoursUntilRelease: number;
    }>;
    releaseEscrow(dto: ReleaseEscrowDto): Promise<{
        success: boolean;
        paymentId: number;
        status: string;
        providerAmount: number;
        platformFee: any;
        message: string;
        notes: string;
    }>;
    refund(dto: RefundPaymentDto): Promise<{
        success: boolean;
        paymentId: number;
        status: string;
        refundedAmount: any;
        reason: string;
        message: string;
    }>;
    getPaymentByOrderId(orderId: number): Promise<any>;
    getAllPayments(filters?: {
        status?: string;
        orderId?: number;
    }): Promise<any>;
    processAutoRelease(): Promise<{
        processed: number;
        results: any[];
    }>;
    private logStatusChange;
    createPaymentIntent(body: any): Promise<{
        paymentId: any;
        clientSecret: string;
        amount: number;
        totalAmount: number;
        remainingAmount: number;
        currency: string;
        status: string;
        isAdvanceOnly: boolean;
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
