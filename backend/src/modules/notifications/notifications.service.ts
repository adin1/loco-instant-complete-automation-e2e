import { Injectable } from '@nestjs/common';

@Injectable()
export class NotificationsService {
  private readonly tokens: any[] = [];

  async register(body: any) {
    const tokenEntry = {
      id: this.tokens.length + 1,
      token: body.token,
      platform: body.platform,
      createdAt: new Date().toISOString(),
    };
    this.tokens.push(tokenEntry);
    return tokenEntry;
  }
}


