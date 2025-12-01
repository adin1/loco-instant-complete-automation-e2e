import { PgService } from '../../infra/db/pg.service';
export interface SendMessageDto {
    orderId: number;
    content: string;
    messageType?: 'text' | 'image' | 'video' | 'audio' | 'file' | 'location' | 'system' | 'price_quote' | 'status_update';
    mediaUrl?: string;
    metadata?: any;
}
export interface MarkReadDto {
    orderId: number;
    beforeTimestamp?: string;
}
export declare class ChatService {
    private pg;
    constructor(pg: PgService);
    sendMessage(dto: SendMessageDto, senderId: number, senderRole: 'customer' | 'provider' | 'system'): Promise<{
        success: boolean;
        message: {
            senderId: number;
            senderRole: "customer" | "system" | "provider";
            orderId: number;
            content: string;
            messageType?: "text" | "image" | "video" | "audio" | "file" | "location" | "system" | "price_quote" | "status_update";
            mediaUrl?: string;
            metadata?: any;
            id: any;
            sentAt: any;
        };
    }>;
    getMessages(orderId: number, limit?: number, before?: string): Promise<any>;
    markRead(dto: MarkReadDto, readerId: number): Promise<{
        success: boolean;
    }>;
    getUnreadCount(orderId: number, userId: number): Promise<{
        unreadCount: number;
    }>;
    getUserChats(userId: number, role: 'customer' | 'provider'): Promise<any>;
    sendSystemMessage(orderId: number, content: string, messageType?: 'system' | 'status_update', metadata?: any): Promise<any>;
    private getProviderUserId;
}
