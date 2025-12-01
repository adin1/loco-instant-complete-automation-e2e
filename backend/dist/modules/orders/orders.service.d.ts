import { PgService } from '../../infra/db/pg.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto, CompleteWorkDto, ConfirmWorkDto } from './dto/update-order.dto';
export declare class OrdersService {
    private pg;
    constructor(pg: PgService);
    getAll(q?: string): Promise<any>;
    getById(id: number): Promise<any>;
    create(dto: CreateOrderDto): Promise<any>;
    update(id: number, dto: UpdateOrderDto): Promise<any>;
    delete(id: number): Promise<{
        success: boolean;
    }>;
    markEnRoute(orderId: number, providerId: number): Promise<{
        success: boolean;
        status: string;
    }>;
    startWork(orderId: number, providerId: number): Promise<{
        success: boolean;
        status: string;
    }>;
    completeWork(orderId: number, providerId: number, dto?: CompleteWorkDto): Promise<{
        success: boolean;
        status: string;
        autoReleaseAt: Date;
        message: string;
    }>;
    confirmWork(orderId: number, customerId: number, dto?: ConfirmWorkDto): Promise<{
        success: boolean;
        status: string;
        message: string;
    }>;
    getByStatus(status: string, customerId?: number, providerId?: number): Promise<any>;
    getTimeline(orderId: number): Promise<any>;
    private logStatusChange;
    private sendSystemMessage;
}
