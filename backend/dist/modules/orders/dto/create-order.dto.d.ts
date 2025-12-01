export declare const ORDER_STATUSES: readonly ["draft", "pending", "payment_pending", "funds_held", "assigned", "provider_en_route", "in_progress", "work_completed", "confirmed", "disputed", "completed", "cancelled", "refunded"];
export type OrderStatus = typeof ORDER_STATUSES[number];
export declare class CreateOrderDto {
    customerId: number;
    serviceId: number;
    providerId?: number;
    status?: string;
    priceEstimate?: number;
    currency?: string;
    originLat: number;
    originLng: number;
    address?: string;
    description?: string;
    scheduledFor?: string;
}
