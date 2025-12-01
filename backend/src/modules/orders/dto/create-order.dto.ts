import { IsInt, IsOptional, IsString, IsNumber, IsIn, IsPositive, IsLatitude, IsLongitude, Min, Length } from 'class-validator';

// Full workflow statuses
export const ORDER_STATUSES = [
  'draft',           // Comandă în curs de creare
  'pending',         // Așteaptă plată/provider
  'payment_pending', // Așteaptă procesarea plății
  'funds_held',      // Fonduri blocate în escrow
  'assigned',        // Provider asignat
  'provider_en_route', // Provider în drum
  'in_progress',     // Lucrare în curs
  'work_completed',  // Marcat finalizat de provider
  'confirmed',       // Confirmat de client
  'disputed',        // În dispută
  'completed',       // Finalizat, bani eliberați
  'cancelled',       // Anulat
  'refunded',        // Rambursat
] as const;

export type OrderStatus = typeof ORDER_STATUSES[number];

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

  @IsOptional()
  @IsString()
  @IsIn(ORDER_STATUSES)
  status?: string;

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

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  scheduledFor?: string; // ISO date string
}
