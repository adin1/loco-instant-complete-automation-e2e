import { OrdersService } from './orders.service';
export declare class OrdersController {
    private readonly svc;
    constructor(svc: OrdersService);
    create(b: any): Promise<{
        id: any;
    }>;
}
