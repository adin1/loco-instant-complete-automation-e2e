import { IsInt, IsOptional, IsString, IsNumber, IsIn, IsPositive, IsUrl } from 'class-validator';

export const EVIDENCE_TYPES = [
  'before_work',
  'during_work', 
  'after_work',
  'test_proof',
  'problem_report',
  'dispute_evidence',
] as const;

export type EvidenceType = typeof EVIDENCE_TYPES[number];

export const MEDIA_TYPES = ['image', 'video'] as const;
export type MediaType = typeof MEDIA_TYPES[number];

export class CreateEvidenceDto {
  @IsInt()
  @IsPositive()
  orderId: number;

  @IsString()
  @IsIn(EVIDENCE_TYPES)
  evidenceType: EvidenceType;

  @IsString()
  @IsIn(MEDIA_TYPES)
  mediaType: MediaType;

  @IsString()
  @IsUrl()
  fileUrl: string;

  @IsOptional()
  @IsString()
  @IsUrl()
  thumbnailUrl?: string;

  @IsOptional()
  @IsNumber()
  fileSizeBytes?: number;

  @IsOptional()
  @IsNumber()
  durationSeconds?: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsNumber()
  locationLat?: number;

  @IsOptional()
  @IsNumber()
  locationLng?: number;
}

export class GetEvidenceDto {
  @IsOptional()
  @IsInt()
  orderId?: number;

  @IsOptional()
  @IsString()
  @IsIn(EVIDENCE_TYPES)
  evidenceType?: EvidenceType;
}

export class UploadRequestDto {
  @IsInt()
  @IsPositive()
  orderId: number;

  @IsString()
  @IsIn(EVIDENCE_TYPES)
  evidenceType: EvidenceType;

  @IsString()
  @IsIn(MEDIA_TYPES)
  mediaType: MediaType;

  @IsString()
  fileName: string;

  @IsNumber()
  fileSize: number;
}

