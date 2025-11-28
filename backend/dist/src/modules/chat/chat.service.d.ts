export declare class ChatService {
    private readonly messages;
    sendMessage(body: any): Promise<{
        success: boolean;
        message: any;
    }>;
}
