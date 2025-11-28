import { RequestsService } from './requests.service';
export declare class RequestsController {
    private readonly requestsService;
    constructor(requestsService: RequestsService);
    findAll(): Promise<any[]>;
    create(body: any): Promise<any>;
    getById(id: string): Promise<any>;
}
