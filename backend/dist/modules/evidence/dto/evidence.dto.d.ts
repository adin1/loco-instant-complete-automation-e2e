export declare const EVIDENCE_TYPES: readonly ["before_work", "during_work", "after_work", "test_proof", "problem_report", "dispute_evidence"];
export type EvidenceType = typeof EVIDENCE_TYPES[number];
export declare const MEDIA_TYPES: readonly ["image", "video"];
export type MediaType = typeof MEDIA_TYPES[number];
export declare class CreateEvidenceDto {
    orderId: number;
    evidenceType: EvidenceType;
    mediaType: MediaType;
    fileUrl: string;
    thumbnailUrl?: string;
    fileSizeBytes?: number;
    durationSeconds?: number;
    description?: string;
    locationLat?: number;
    locationLng?: number;
}
export declare class GetEvidenceDto {
    orderId?: number;
    evidenceType?: EvidenceType;
}
export declare class UploadRequestDto {
    orderId: number;
    evidenceType: EvidenceType;
    mediaType: MediaType;
    fileName: string;
    fileSize: number;
}
