import { NotificationsService } from './notifications.service';
export declare class NotificationsController {
    private readonly notificationsService;
    constructor(notificationsService: NotificationsService);
    register(body: any): Promise<{
        id: number;
        token: any;
        platform: any;
        createdAt: string;
    }>;
}
