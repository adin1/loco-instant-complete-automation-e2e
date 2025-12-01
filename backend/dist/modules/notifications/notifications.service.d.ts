export declare class NotificationsService {
    private readonly tokens;
    register(body: any): Promise<{
        id: number;
        token: any;
        platform: any;
        createdAt: string;
    }>;
}
