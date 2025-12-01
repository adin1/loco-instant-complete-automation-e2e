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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OffersController = void 0;
const common_1 = require("@nestjs/common");
const offers_service_1 = require("./offers.service");
let OffersController = class OffersController {
    constructor(offersService) {
        this.offersService = offersService;
    }
    async findAll() {
        return this.offersService.findAll();
    }
    async create(body) {
        return this.offersService.create(body);
    }
    async acceptOffer(requestId, offerId) {
        return this.offersService.acceptOffer(requestId, offerId);
    }
};
exports.OffersController = OffersController;
__decorate([
    (0, common_1.Get)('offers'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], OffersController.prototype, "findAll", null);
__decorate([
    (0, common_1.Post)('offers'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], OffersController.prototype, "create", null);
__decorate([
    (0, common_1.Post)('requests/:id/accept/:offerId'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Param)('offerId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], OffersController.prototype, "acceptOffer", null);
exports.OffersController = OffersController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [offers_service_1.OffersService])
], OffersController);
//# sourceMappingURL=offers.controller.js.map