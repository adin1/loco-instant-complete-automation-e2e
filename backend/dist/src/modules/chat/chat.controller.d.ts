import { ChatService } from './chat.service';
export declare class ChatController {
    private readonly chatService;
    constructor(chatService: ChatService);
    sendMessage(body: any): Promise<{
        success: boolean;
        message: any;
    }>;
}
