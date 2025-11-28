import { IsInt, IsOptional, IsString, IsNumber, IsIn } from 'class-validator';

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
  @IsIn(['pending','assigned','in_progress','completed','canceled'])
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
