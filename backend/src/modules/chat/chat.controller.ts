import { Controller, Post, Get, Body, Param, Query, ParseIntPipe } from '@nestjs/common';
import { ChatService, SendMessageDto, MarkReadDto } from './chat.service';

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  /**
   * Send a message
   */
  @Post('send')
  async sendMessage(@Body() body: SendMessageDto) {
    // TODO: Get sender info from auth token
    const senderId = 1; // Mock user ID
    const senderRole = 'customer' as const;
    return this.chatService.sendMessage(body, senderId, senderRole);
  }

  /**
   * Get messages for an order
   */
  @Get('order/:orderId')
  async getMessages(
    @Param('orderId', ParseIntPipe) orderId: number,
    @Query('limit') limit?: string,
    @Query('before') before?: string,
  ) {
    return this.chatService.getMessages(
      orderId,
      limit ? parseInt(limit, 10) : 50,
      before
    );
  }

  /**
   * Mark messages as read
   */
  @Post('mark-read')
  async markRead(@Body() body: MarkReadDto) {
    // TODO: Get reader ID from auth token
    const readerId = 1; // Mock user ID
    return this.chatService.markRead(body, readerId);
  }

  /**
   * Get unread count for an order
   */
  @Get('order/:orderId/unread')
  async getUnreadCount(@Param('orderId', ParseIntPipe) orderId: number) {
    // TODO: Get user ID from auth token
    const userId = 1;
    return this.chatService.getUnreadCount(orderId, userId);
  }

  /**
   * Get all chats for current user
   */
  @Get('my-chats')
  async getMyChats(@Query('role') role?: string) {
    // TODO: Get user ID and role from auth token
    const userId = 1;
    const userRole = (role === 'provider' ? 'provider' : 'customer') as 'customer' | 'provider';
    return this.chatService.getUserChats(userId, userRole);
  }

  /**
   * Send system message (internal/admin)
   */
  @Post('system')
  async sendSystemMessage(
    @Body() body: { orderId: number; content: string; messageType?: 'system' | 'status_update'; metadata?: any }
  ) {
    return this.chatService.sendSystemMessage(body.orderId, body.content, body.messageType, body.metadata);
  }
}
