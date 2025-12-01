import { ChatService, SendMessageDto, MarkReadDto } from './chat.service';
export declare class ChatController {
    private readonly chatService;
    constructor(chatService: ChatService);
    sendMessage(body: SendMessageDto): Promise<{
        success: boolean;
        message: {
            senderId: number;
            senderRole: "provider" | "customer" | "system";
            orderId: number;
            content: string;
            messageType?: "text" | "image" | "video" | "audio" | "file" | "location" | "system" | "price_quote" | "status_update";
            mediaUrl?: string;
            metadata?: any;
            id: any;
            sentAt: any;
        };
    }>;
    getMessages(orderId: number, limit?: string, before?: string): Promise<any>;
    markRead(body: MarkReadDto): Promise<{
        success: boolean;
    }>;
    getUnreadCount(orderId: number): Promise<{
        unreadCount: number;
    }>;
    getMyChats(role?: string): Promise<any>;
    sendSystemMessage(body: {
        orderId: number;
        content: string;
        messageType?: 'system' | 'status_update';
        metadata?: any;
    }): Promise<any>;
}
