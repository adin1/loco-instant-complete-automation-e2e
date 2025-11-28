import { Injectable } from '@nestjs/common';
import { RequestsService } from '../requests/requests.service';

@Injectable()
export class OffersService {
  constructor(private readonly requestsService: RequestsService) {}

  private readonly offers: any[] = [];

  async findAll() {
    return this.offers;
  }

  async create(body: any) {
    const offer = { id: this.offers.length + 1, status: 'open', ...body };
    this.offers.push(offer);
    return offer;
  }

  async acceptOffer(requestId: string, offerId: string) {
    const request = await this.requestsService.getById(requestId);
    const numericOfferId = Number(offerId);
    const offer = this.offers.find((o) => o.id === numericOfferId);
    if (!offer) {
      return { success: false, message: 'Offer not found' };
    }
    offer.status = 'accepted';
    request.status = 'assigned';
    return {
      success: true,
      request,
      offer,
    };
  }
}


