import { Injectable } from '@nestjs/common';

@Injectable()
export class ChatService {
  private readonly messages: any[] = [];

  async sendMessage(body: any) {
    const message = {
      id: this.messages.length + 1,
      sentAt: new Date().toISOString(),
      ...body,
    };
    this.messages.push(message);
    // TODO: Emit message via WebSocket (Socket.IO) once gateway is added.
    return { success: true, message };
  }
}


