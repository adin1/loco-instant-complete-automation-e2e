import { Controller, Get, Query, Param, ParseIntPipe, Post, Body, Patch, Delete, UsePipes, ValidationPipe } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto, CompleteWorkDto, ConfirmWorkDto } from './dto/update-order.dto';

@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get()
  async getAll(@Query('q') q?: string) {
    return this.ordersService.getAll(q);
  }

  @Get('status/:status')
  async getByStatus(
    @Param('status') status: string,
    @Query('customerId') customerId?: string,
    @Query('providerId') providerId?: string,
  ) {
    return this.ordersService.getByStatus(
      status,
      customerId ? parseInt(customerId, 10) : undefined,
      providerId ? parseInt(providerId, 10) : undefined,
    );
  }

  @Get(':id')
  async getById(@Param('id', ParseIntPipe) id: number) {
    return this.ordersService.getById(id);
  }

  @Get(':id/timeline')
  async getTimeline(@Param('id', ParseIntPipe) id: number) {
    return this.ordersService.getTimeline(id);
  }

  @Post()
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async create(@Body() body: CreateOrderDto) {
    return this.ordersService.create(body);
  }

  @Patch(':id')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async update(@Param('id', ParseIntPipe) id: number, @Body() body: UpdateOrderDto) {
    return this.ordersService.update(id, body);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.ordersService.delete(id);
  }

  // ===============================
  // WORKFLOW ENDPOINTS
  // ===============================

  /**
   * Provider marks as en route
   */
  @Post(':id/en-route')
  async markEnRoute(@Param('id', ParseIntPipe) id: number) {
    // TODO: Get provider ID from auth token
    const providerId = 1;
    return this.ordersService.markEnRoute(id, providerId);
  }

  /**
   * Provider starts work
   */
  @Post(':id/start-work')
  async startWork(@Param('id', ParseIntPipe) id: number) {
    // TODO: Get provider ID from auth token
    const providerId = 1;
    return this.ordersService.startWork(id, providerId);
  }

  /**
   * Provider completes work
   */
  @Post(':id/complete-work')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async completeWork(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: CompleteWorkDto,
  ) {
    // TODO: Get provider ID from auth token
    const providerId = 1;
    return this.ordersService.completeWork(id, providerId, body);
  }

  /**
   * Customer confirms work
   */
  @Post(':id/confirm')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async confirmWork(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: ConfirmWorkDto,
  ) {
    // TODO: Get customer ID from auth token
    const customerId = 1;
    return this.ordersService.confirmWork(id, customerId, body);
  }
}
