import { DisputesService } from './disputes.service';
import { CreateDisputeDto, ScheduleRevisitDto, ResolveDisputeDto, ProviderResponseDto } from './dto/dispute.dto';
export declare class DisputesController {
    private readonly disputesService;
    constructor(disputesService: DisputesService);
    create(body: CreateDisputeDto): Promise<any>;
    getById(id: number): Promise<any>;
    getByOrderId(orderId: number): Promise<any>;
    getAll(status?: string, category?: string): Promise<any>;
    providerResponse(body: ProviderResponseDto): Promise<{
        success: boolean;
        message: string;
    }>;
    scheduleRevisit(body: ScheduleRevisitDto): Promise<{
        success: boolean;
        message: string;
    }>;
    resolve(body: ResolveDisputeDto): Promise<{
        success: boolean;
        message: string;
    }>;
    getStats(): Promise<{
        byStatus: Record<string, number>;
        byCategory: Record<string, number>;
    }>;
}
