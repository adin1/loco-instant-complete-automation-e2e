import { Controller, Post, Get, Delete, Body, Param, Query, ParseIntPipe, UsePipes, ValidationPipe } from '@nestjs/common';
import { EvidenceService } from './evidence.service';
import { CreateEvidenceDto, UploadRequestDto } from './dto/evidence.dto';

@Controller('evidence')
export class EvidenceController {
  constructor(private readonly evidenceService: EvidenceService) {}

  /**
   * Create evidence record (after upload)
   */
  @Post()
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async create(@Body() body: CreateEvidenceDto) {
    // TODO: Get uploadedBy from auth token
    const uploadedBy = 1; // Mock user ID
    return this.evidenceService.create(body, uploadedBy);
  }

  /**
   * Get upload URL for file
   */
  @Post('upload-url')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async getUploadUrl(@Body() body: UploadRequestDto) {
    return this.evidenceService.getUploadUrl(body);
  }

  /**
   * Get evidence for an order
   */
  @Get('order/:orderId')
  async getByOrderId(@Param('orderId', ParseIntPipe) orderId: number) {
    return this.evidenceService.getByOrderId(orderId);
  }

  /**
   * Get evidence by type for an order
   */
  @Get('order/:orderId/type/:type')
  async getByType(
    @Param('orderId', ParseIntPipe) orderId: number,
    @Param('type') type: string,
  ) {
    return this.evidenceService.getByType(orderId, type);
  }

  /**
   * Check if required evidence exists
   */
  @Get('order/:orderId/check')
  async checkRequired(@Param('orderId', ParseIntPipe) orderId: number) {
    return this.evidenceService.checkRequiredEvidence(orderId);
  }

  /**
   * Get all evidence for dispute review
   */
  @Get('order/:orderId/dispute')
  async getForDispute(@Param('orderId', ParseIntPipe) orderId: number) {
    return this.evidenceService.getForDispute(orderId);
  }

  /**
   * Delete evidence (admin only)
   */
  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number) {
    return this.evidenceService.delete(id);
  }
}

