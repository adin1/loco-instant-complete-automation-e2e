import { ProvidersService } from './providers.service';
export declare class ProvidersController {
    private readonly svc;
    constructor(svc: ProvidersService);
    getOne(id: string): Promise<any>;
    getStatus(id: string): Promise<string>;
    setStatus(id: string, b: {
        status: 'online' | 'busy' | 'offline';
    }): Promise<{
        id: number;
        status: string;
    }>;
}
