import { Injectable, NotFoundException } from '@nestjs/common';

@Injectable()
export class RequestsService {
  private readonly requests: any[] = [];

  async findAll() {
    return this.requests;
  }

  async create(body: any) {
    const request = { id: this.requests.length + 1, status: 'open', ...body };
    this.requests.push(request);
    return request;
  }

  async getById(id: string) {
    const numericId = Number(id);
    const req = this.requests.find((r) => r.id === numericId);
    if (!req) throw new NotFoundException('Request not found');
    return req;
  }
}


