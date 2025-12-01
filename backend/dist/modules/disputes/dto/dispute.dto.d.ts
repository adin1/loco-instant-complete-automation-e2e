export declare const DISPUTE_CATEGORIES: readonly ["work_not_completed", "poor_quality", "different_from_agreed", "damage_caused", "no_show", "overcharged", "payment_issue", "communication", "other"];
export type DisputeCategory = typeof DISPUTE_CATEGORIES[number];
export declare const DISPUTE_STATUSES: readonly ["open", "under_review", "awaiting_response", "scheduled_revisit", "resolved_refund", "resolved_partial", "resolved_redo", "rejected", "closed"];
export type DisputeStatus = typeof DISPUTE_STATUSES[number];
export declare class CreateDisputeDto {
    orderId: number;
    category: DisputeCategory;
    title: string;
    description: string;
    whatNotWorking?: string;
    technicalDetails?: string;
    evidenceUrls?: string[];
}
export declare class UpdateDisputeDto {
    status?: DisputeStatus;
    resolutionNotes?: string;
    resolutionAmount?: number;
}
export declare class ScheduleRevisitDto {
    disputeId: number;
    scheduledAt: string;
    cost?: number;
    notes?: string;
}
export declare class ResolveDisputeDto {
    disputeId: number;
    resolution: 'resolved_refund' | 'resolved_partial' | 'resolved_redo' | 'rejected';
    refundAmount?: number;
    resolutionNotes: string;
}
export declare class ProviderResponseDto {
    disputeId: number;
    response: string;
    evidenceUrls?: string[];
    acceptRevisit?: boolean;
}
