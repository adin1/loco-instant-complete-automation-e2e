import { PgService } from '../../infra/db/pg.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
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
}
