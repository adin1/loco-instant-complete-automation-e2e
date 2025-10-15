export declare class PgService {
    private pool;
    query<T = any>(text: string, params?: any[]): Promise<any>;
}
