import { IsInt, IsOptional, IsString, IsNumber, IsIn, IsPositive, IsLatitude, IsLongitude, Min, Length } from 'class-validator';

export class CreateOrderDto {
  @IsInt()
  @IsPositive()
  customerId: number;

  @IsInt()
  @IsPositive()
  serviceId: number;

  @IsOptional()
  @IsInt()
  @IsPositive()
  providerId?: number;

  @IsString()
  @IsIn(['pending','assigned','in_progress','completed','canceled'])
  status: string;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  priceEstimate?: number;

  @IsOptional()
  @IsString()
  @Length(3, 3)
  currency?: string;

  @IsLatitude()
  originLat: number;

  @IsLongitude()
  originLng: number;
}
