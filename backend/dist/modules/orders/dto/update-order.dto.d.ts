export declare class UpdateOrderDto {
    customerId?: number;
    serviceId?: number;
    providerId?: number;
    status?: string;
    priceEstimate?: number;
    currency?: string;
    originLat?: number;
    originLng?: number;
}
export declare class CompleteWorkDto {
    completionNotes?: string;
}
export declare class ConfirmWorkDto {
    rating?: number;
    feedback?: string;
}
