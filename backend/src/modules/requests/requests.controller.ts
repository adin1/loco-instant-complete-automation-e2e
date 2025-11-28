import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { RequestsService } from './requests.service';

@Controller('requests')
export class RequestsController {
  constructor(private readonly requestsService: RequestsService) {}

  @Get()
  async findAll() {
    return this.requestsService.findAll();
  }

  @Post()
  async create(@Body() body: any) {
    return this.requestsService.create(body);
  }

  @Get(':id')
  async getById(@Param('id') id: string) {
    return this.requestsService.getById(id);
  }
}


