import { Controller, Get, Param, Post, Body, Query } from '@nestjs/common';
import { ProvidersService } from './providers.service';

@Controller('providers')
export class ProvidersController {
  constructor(private readonly svc: ProvidersService) {}

  @Get()
  listAll() { return this.svc.listAll(); }

  @Get('nearby')
  nearby(
    @Query('lat') lat: string,
    @Query('lon') lon: string,
    @Query('radiusMeters') radiusMeters?: string,
  ) {
    return this.svc.findNearby(Number(lat), Number(lon), radiusMeters ? Number(radiusMeters) : 5000);
  }

  @Get(':id') getOne(@Param('id') id: string) { return this.svc.getOne(Number(id)); }
  @Get(':id/status') getStatus(@Param('id') id: string) { return this.svc.getStatus(Number(id)); }
  @Post(':id/status') setStatus(@Param('id') id: string, @Body() b: { status: 'online'|'busy'|'offline' }) { return this.svc.setStatus(Number(id), b.status); }
}