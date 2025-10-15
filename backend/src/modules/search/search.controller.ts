import { Controller, Get, Query } from '@nestjs/common';
import { SearchService } from './search.service';

@Controller('search')
export class SearchController {
  constructor(private readonly svc: SearchService) {}
  @Get('providers')
  providers(@Query('q') q: string, @Query('lat') lat: string, @Query('lon') lon: string, @Query('radius') radius = '5km') {
    return this.svc.searchProviders(q, Number(lat), Number(lon), radius);
  }
}