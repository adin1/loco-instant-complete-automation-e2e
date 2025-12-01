import { PgService } from '../../infra/db/pg.service';
import { CreateEvidenceDto, UploadRequestDto } from './dto/evidence.dto';
export declare class EvidenceService {
    private pg;
    constructor(pg: PgService);
    create(dto: CreateEvidenceDto, uploadedBy: number): Promise<any>;
    getByOrderId(orderId: number): Promise<any>;
    getByType(orderId: number, evidenceType: string): Promise<any>;
    checkRequiredEvidence(orderId: number): Promise<{
        hasBefore: any;
        hasAfter: any;
        hasTestProof: any;
        isComplete: any;
        evidence: any;
    }>;
    getUploadUrl(dto: UploadRequestDto): Promise<{
        uploadUrl: string;
        fileUrl: string;
        fileName: string;
        expiresIn: number;
    }>;
    delete(evidenceId: number): Promise<{
        success: boolean;
        deleted: any;
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
}
