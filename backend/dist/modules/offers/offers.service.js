"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OffersService = void 0;
const common_1 = require("@nestjs/common");
const requests_service_1 = require("../requests/requests.service");
let OffersService = class OffersService {
    constructor(requestsService) {
        this.requestsService = requestsService;
        this.offers = [];
    }
    async findAll() {
        return this.offers;
    }
    async create(body) {
        const offer = { id: this.offers.length + 1, status: 'open', ...body };
        this.offers.push(offer);
        return offer;
    }
    async acceptOffer(requestId, offerId) {
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
};
exports.OffersService = OffersService;
exports.OffersService = OffersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [requests_service_1.RequestsService])
], OffersService);
//# sourceMappingURL=offers.service.js.map