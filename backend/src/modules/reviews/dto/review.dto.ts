import { IsInt, IsOptional, IsString, IsNumber, IsIn, IsPositive, Min, Max, IsBoolean } from 'class-validator';

export class CreateReviewDto {
  @IsInt()
  @IsPositive()
  orderId: number;

  @IsInt()
  @Min(1)
  @Max(5)
  overallRating: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  qualityRating?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  punctualityRating?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  communicationRating?: number;

  @IsOptional()
  @IsString()
  reviewText?: string;

  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;
}

export class RespondToReviewDto {
  @IsInt()
  @IsPositive()
  reviewId: number;

  @IsString()
  responseText: string;
}

export const BLOCK_REASONS = [
  'abusive',
  'non_payment',
  'fraud',
  'poor_quality',
  'harassment',
  'other',
] as const;

export type BlockReason = typeof BLOCK_REASONS[number];

export class BlockUserDto {
  @IsInt()
  @IsPositive()
  userId: number;

  @IsString()
  @IsIn(BLOCK_REASONS)
  reason: BlockReason;

  @IsOptional()
  @IsString()
  notes?: string;
}

