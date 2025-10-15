import { PgService } from '../../infra/db/pg.service';
export declare class OrdersService {
    private pg;
    constructor(pg: PgService);
    create(b: any): Promise<{
        id: any;
    }>;
}
