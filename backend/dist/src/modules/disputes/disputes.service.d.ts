import { PgService } from '../../infra/db/pg.service';
import { CreateDisputeDto, ScheduleRevisitDto, ResolveDisputeDto, ProviderResponseDto } from './dto/dispute.dto';
export declare class DisputesService {
    private pg;
    constructor(pg: PgService);
    create(dto: CreateDisputeDto, filedBy: number, filedByRole: 'customer' | 'provider'): Promise<any>;
    getById(disputeId: number): Promise<any>;
    getByOrderId(orderId: number): Promise<any>;
    getAll(filters?: {
        status?: string;
        category?: string;
    }): Promise<any>;
    providerResponse(dto: ProviderResponseDto, providerId: number): Promise<{
        success: boolean;
        message: string;
    }>;
    scheduleRevisit(dto: ScheduleRevisitDto): Promise<{
        success: boolean;
        message: string;
    }>;
    resolve(dto: ResolveDisputeDto, resolvedBy: number): Promise<{
        success: boolean;
        message: string;
    }>;
    getStats(): Promise<{
        byStatus: Record<string, number>;
        byCategory: Record<string, number>;
    }>;
    private getProviderUserId;
    private sendDisputeNotification;
}
