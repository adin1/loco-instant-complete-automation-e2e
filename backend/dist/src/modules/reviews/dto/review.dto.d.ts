export declare class CreateReviewDto {
    orderId: number;
    overallRating: number;
    qualityRating?: number;
    punctualityRating?: number;
    communicationRating?: number;
    reviewText?: string;
    isPublic?: boolean;
}
export declare class RespondToReviewDto {
    reviewId: number;
    responseText: string;
}
export declare const BLOCK_REASONS: readonly ["abusive", "non_payment", "fraud", "poor_quality", "harassment", "other"];
export type BlockReason = typeof BLOCK_REASONS[number];
export declare class BlockUserDto {
    userId: number;
    reason: BlockReason;
    notes?: string;
}
