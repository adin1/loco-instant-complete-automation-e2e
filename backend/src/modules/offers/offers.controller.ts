import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { OffersService } from './offers.service';

@Controller()
export class OffersController {
  constructor(private readonly offersService: OffersService) {}

  @Get('offers')
  async findAll() {
    return this.offersService.findAll();
  }

  @Post('offers')
  async create(@Body() body: any) {
    return this.offersService.create(body);
  }

  @Post('requests/:id/accept/:offerId')
  async acceptOffer(
    @Param('id') requestId: string,
    @Param('offerId') offerId: string,
  ) {
    return this.offersService.acceptOffer(requestId, offerId);
  }
}


