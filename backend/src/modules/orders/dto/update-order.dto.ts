import { IsInt, IsOptional, IsString, IsNumber, IsIn } from 'class-validator';
import { ORDER_STATUSES } from './create-order.dto';

export class UpdateOrderDto {
  @IsOptional()
  @IsInt()
  customerId?: number;

  @IsOptional()
  @IsInt()
  serviceId?: number;

  @IsOptional()
  @IsInt()
  providerId?: number;

  @IsOptional()
  @IsString()
  @IsIn(ORDER_STATUSES)
  status?: string;

  @IsOptional()
  @IsNumber()
  priceEstimate?: number;

  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  @IsNumber()
  originLat?: number;

  @IsOptional()
  @IsNumber()
  originLng?: number;
}

// DTO for completing work (provider)
export class CompleteWorkDto {
  @IsOptional()
  @IsString()
  completionNotes?: string;
}

// DTO for confirming work (customer)
export class ConfirmWorkDto {
  @IsOptional()
  @IsInt()
  rating?: number;

  @IsOptional()
  @IsString()
  feedback?: string;
}
