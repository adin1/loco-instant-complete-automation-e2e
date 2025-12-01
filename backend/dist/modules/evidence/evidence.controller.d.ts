import { EvidenceService } from './evidence.service';
import { CreateEvidenceDto, UploadRequestDto } from './dto/evidence.dto';
export declare class EvidenceController {
    private readonly evidenceService;
    constructor(evidenceService: EvidenceService);
    create(body: CreateEvidenceDto): Promise<any>;
    getUploadUrl(body: UploadRequestDto): Promise<{
        uploadUrl: string;
        fileUrl: string;
        fileName: string;
        expiresIn: number;
    }>;
    getByOrderId(orderId: number): Promise<any>;
    getByType(orderId: number, type: string): Promise<any>;
    checkRequired(orderId: number): Promise<{
        hasBefore: any;
        hasAfter: any;
        hasTestProof: any;
        isComplete: any;
        evidence: any;
    }>;
    getForDispute(orderId: number): Promise<{
        all: any;
        grouped: Record<string, any[]>;
        summary: {
            beforeWork: number;
            duringWork: number;
            afterWork: number;
            testProof: number;
            problemReport: number;
            disputeEvidence: number;
        };
    }>;
    delete(id: number): Promise<{
        success: boolean;
        deleted: any;
    }>;
}
