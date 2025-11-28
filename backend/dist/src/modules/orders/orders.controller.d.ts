import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
export declare class OrdersController {
    private readonly ordersService;
    constructor(ordersService: OrdersService);
    getAll(q?: string): Promise<any>;
    getById(id: number): Promise<any>;
    create(body: CreateOrderDto): Promise<any>;
    update(id: number, body: UpdateOrderDto): Promise<any>;
    remove(id: number): Promise<{
        success: boolean;
    }>;
}
