import { NestMiddleware } from '@nestjs/common';
export declare class TenantMiddleware implements NestMiddleware {
    private pool;
    use(req: any, res: any, next: () => void): Promise<void>;
}
