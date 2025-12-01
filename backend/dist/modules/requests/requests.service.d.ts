export declare class RequestsService {
    private readonly requests;
    findAll(): Promise<any[]>;
    create(body: any): Promise<any>;
    getById(id: string): Promise<any>;
}
