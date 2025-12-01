import { IsInt, IsOptional, IsString, IsNumber, IsIn, IsPositive, Min, Max, IsBoolean } from 'class-validator';

export const PAYMENT_STATUSES = [
  'pending',
  'authorized',
  'advance_paid',
  'fully_paid',
  'held',
  'released',
  'refunded',
  'disputed',
  'failed',
] as const;

export type PaymentStatus = typeof PAYMENT_STATUSES[number];

export class CreatePaymentIntentDto {
  @IsInt()
  @IsPositive()
  orderId: number;

  @IsNumber()
  @Min(1)
  amount: number;

  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  @IsBoolean()
  isAdvanceOnly?: boolean; // true = doar avans (30-50%)

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  advancePercentage?: number; // default 30%
}

export class AuthorizePaymentDto {
  @IsInt()
  @IsPositive()
  paymentId: number;

  @IsString()
  stripePaymentMethodId: string;
}

export class CapturePaymentDto {
  @IsInt()
  @IsPositive()
  paymentId: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number; // if not provided, captures full authorized amount
}

export class ReleaseEscrowDto {
  @IsInt()
  @IsPositive()
  paymentId: number;

  @IsOptional()
  @IsString()
  notes?: string;
}

export class RefundPaymentDto {
  @IsInt()
  @IsPositive()
  paymentId: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number; // partial refund

  @IsString()
  reason: string;
}

export class PaymentWebhookDto {
  @IsString()
  stripeSignature: string;

  payload: any;
}

