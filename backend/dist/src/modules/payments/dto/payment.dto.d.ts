export declare const PAYMENT_STATUSES: readonly ["pending", "authorized", "advance_paid", "fully_paid", "held", "released", "refunded", "disputed", "failed"];
export type PaymentStatus = typeof PAYMENT_STATUSES[number];
export declare class CreatePaymentIntentDto {
    orderId: number;
    amount: number;
    currency?: string;
    isAdvanceOnly?: boolean;
    advancePercentage?: number;
}
export declare class AuthorizePaymentDto {
    paymentId: number;
    stripePaymentMethodId: string;
}
export declare class CapturePaymentDto {
    paymentId: number;
    amount?: number;
}
export declare class ReleaseEscrowDto {
    paymentId: number;
    notes?: string;
}
export declare class RefundPaymentDto {
    paymentId: number;
    amount?: number;
    reason: string;
}
export declare class PaymentWebhookDto {
    stripeSignature: string;
    payload: any;
}
