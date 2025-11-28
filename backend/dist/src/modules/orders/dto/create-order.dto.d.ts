export declare class CreateOrderDto {
    customerId: number;
    serviceId: number;
    providerId?: number;
    status: string;
    priceEstimate?: number;
    currency?: string;
    originLat: number;
    originLng: number;
}
