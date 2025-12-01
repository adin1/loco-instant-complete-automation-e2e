import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto, CompleteWorkDto, ConfirmWorkDto } from './dto/update-order.dto';
export declare class OrdersController {
    private readonly ordersService;
    constructor(ordersService: OrdersService);
    getAll(q?: string): Promise<any>;
    getByStatus(status: string, customerId?: string, providerId?: string): Promise<any>;
    getById(id: number): Promise<any>;
    getTimeline(id: number): Promise<any>;
    create(body: CreateOrderDto): Promise<any>;
    update(id: number, body: UpdateOrderDto): Promise<any>;
    remove(id: number): Promise<{
        success: boolean;
    }>;
    markEnRoute(id: number): Promise<{
        success: boolean;
        status: string;
    }>;
    startWork(id: number): Promise<{
        success: boolean;
        status: string;
    }>;
    completeWork(id: number, body: CompleteWorkDto): Promise<{
        success: boolean;
        status: string;
        autoReleaseAt: Date;
        message: string;
    }>;
    confirmWork(id: number, body: ConfirmWorkDto): Promise<{
        success: boolean;
        status: string;
        message: string;
    }>;
}
