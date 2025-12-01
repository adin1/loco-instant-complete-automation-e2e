import { IsInt, IsOptional, IsString, IsNumber, IsIn, IsPositive, IsDateString, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export const DISPUTE_CATEGORIES = [
  'work_not_completed',
  'poor_quality',
  'different_from_agreed',
  'damage_caused',
  'no_show',
  'overcharged',
  'payment_issue',
  'communication',
  'other',
] as const;

export type DisputeCategory = typeof DISPUTE_CATEGORIES[number];

export const DISPUTE_STATUSES = [
  'open',
  'under_review',
  'awaiting_response',
  'scheduled_revisit',
  'resolved_refund',
  'resolved_partial',
  'resolved_redo',
  'rejected',
  'closed',
] as const;

export type DisputeStatus = typeof DISPUTE_STATUSES[number];

export class CreateDisputeDto {
  @IsInt()
  @IsPositive()
  orderId: number;

  @IsString()
  @IsIn(DISPUTE_CATEGORIES)
  category: DisputeCategory;

  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsOptional()
  @IsString()
  whatNotWorking?: string;

  @IsOptional()
  @IsString()
  technicalDetails?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  evidenceUrls?: string[];
}

export class UpdateDisputeDto {
  @IsOptional()
  @IsString()
  @IsIn(DISPUTE_STATUSES)
  status?: DisputeStatus;

  @IsOptional()
  @IsString()
  resolutionNotes?: string;

  @IsOptional()
  @IsNumber()
  resolutionAmount?: number;
}

export class ScheduleRevisitDto {
  @IsInt()
  @IsPositive()
  disputeId: number;

  @IsDateString()
  scheduledAt: string;

  @IsOptional()
  @IsNumber()
  cost?: number; // 0 = free revisit

  @IsOptional()
  @IsString()
  notes?: string;
}

export class ResolveDisputeDto {
  @IsInt()
  @IsPositive()
  disputeId: number;

  @IsString()
  @IsIn(['resolved_refund', 'resolved_partial', 'resolved_redo', 'rejected'])
  resolution: 'resolved_refund' | 'resolved_partial' | 'resolved_redo' | 'rejected';

  @IsOptional()
  @IsNumber()
  refundAmount?: number;

  @IsString()
  resolutionNotes: string;
}

export class ProviderResponseDto {
  @IsInt()
  @IsPositive()
  disputeId: number;

  @IsString()
  response: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  evidenceUrls?: string[];

  @IsOptional()
  acceptRevisit?: boolean;
}

