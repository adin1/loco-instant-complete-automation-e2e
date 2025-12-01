import { Controller, Post, Get, Patch, Body, Param, Query, ParseIntPipe, UsePipes, ValidationPipe } from '@nestjs/common';
import { DisputesService } from './disputes.service';
import { 
  CreateDisputeDto, 
  ScheduleRevisitDto, 
  ResolveDisputeDto,
  ProviderResponseDto 
} from './dto/dispute.dto';

@Controller('disputes')
export class DisputesController {
  constructor(private readonly disputesService: DisputesService) {}

  /**
   * Create a new dispute (report problem)
   */
  @Post()
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async create(@Body() body: CreateDisputeDto) {
    // TODO: Get user info from auth token
    const filedBy = 1; // Mock customer ID
    const filedByRole = 'customer' as const;
    return this.disputesService.create(body, filedBy, filedByRole);
  }

  /**
   * Get dispute by ID
   */
  @Get(':id')
  async getById(@Param('id', ParseIntPipe) id: number) {
    return this.disputesService.getById(id);
  }

  /**
   * Get disputes for an order
   */
  @Get('order/:orderId')
  async getByOrderId(@Param('orderId', ParseIntPipe) orderId: number) {
    return this.disputesService.getByOrderId(orderId);
  }

  /**
   * Get all disputes (admin)
   */
  @Get()
  async getAll(
    @Query('status') status?: string,
    @Query('category') category?: string,
  ) {
    return this.disputesService.getAll({ status, category });
  }

  /**
   * Provider responds to dispute
   */
  @Post('respond')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async providerResponse(@Body() body: ProviderResponseDto) {
    // TODO: Get provider ID from auth token
    const providerId = 1; // Mock provider ID
    return this.disputesService.providerResponse(body, providerId);
  }

  /**
   * Schedule revisit
   */
  @Post('schedule-revisit')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async scheduleRevisit(@Body() body: ScheduleRevisitDto) {
    return this.disputesService.scheduleRevisit(body);
  }

  /**
   * Resolve dispute (admin)
   */
  @Post('resolve')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async resolve(@Body() body: ResolveDisputeDto) {
    // TODO: Get admin ID from auth token
    const resolvedBy = 1; // Mock admin ID
    return this.disputesService.resolve(body, resolvedBy);
  }

  /**
   * Get dispute statistics
   */
  @Get('stats/overview')
  async getStats() {
    return this.disputesService.getStats();
  }
}

