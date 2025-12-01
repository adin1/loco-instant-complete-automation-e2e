import { Controller, Post, Get, Body, Param, Query, ParseIntPipe, UsePipes, ValidationPipe } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { 
  CreatePaymentIntentDto, 
  AuthorizePaymentDto, 
  CapturePaymentDto,
  ReleaseEscrowDto,
  RefundPaymentDto 
} from './dto/payment.dto';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  /**
   * Create payment intent (start payment flow)
   */
  @Post('intent')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async createIntent(@Body() body: CreatePaymentIntentDto) {
    return this.paymentsService.createIntent(body);
  }

  /**
   * Authorize payment (pre-auth card)
   */
  @Post('authorize')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async authorize(@Body() body: AuthorizePaymentDto) {
    return this.paymentsService.authorize(body);
  }

  /**
   * Capture payment (charge the card)
   */
  @Post('capture')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async capture(@Body() body: CapturePaymentDto) {
    return this.paymentsService.capture(body);
  }

  /**
   * Release escrow to provider
   */
  @Post('release')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async releaseEscrow(@Body() body: ReleaseEscrowDto) {
    return this.paymentsService.releaseEscrow(body);
  }

  /**
   * Refund payment
   */
  @Post('refund')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async refund(@Body() body: RefundPaymentDto) {
    return this.paymentsService.refund(body);
  }

  /**
   * Get payment by order ID
   */
  @Get('order/:orderId')
  async getByOrderId(@Param('orderId', ParseIntPipe) orderId: number) {
    return this.paymentsService.getPaymentByOrderId(orderId);
  }

  /**
   * Get all payments (admin)
   */
  @Get()
  async getAll(
    @Query('status') status?: string,
    @Query('orderId') orderId?: string,
  ) {
    return this.paymentsService.getAllPayments({
      status,
      orderId: orderId ? parseInt(orderId, 10) : undefined,
    });
  }

  /**
   * Process auto-release (cron endpoint)
   */
  @Post('process-auto-release')
  async processAutoRelease() {
    return this.paymentsService.processAutoRelease();
  }

  // Legacy endpoint for backwards compatibility
  @Post('confirm')
  async confirm(@Body() body: any) {
    return this.paymentsService.confirm(body);
  }
}
