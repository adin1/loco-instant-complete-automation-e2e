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
exports.DisputesController = void 0;
const common_1 = require("@nestjs/common");
const disputes_service_1 = require("./disputes.service");
const dispute_dto_1 = require("./dto/dispute.dto");
let DisputesController = class DisputesController {
    constructor(disputesService) {
        this.disputesService = disputesService;
    }
    async create(body) {
        const filedBy = 1;
        const filedByRole = 'customer';
        return this.disputesService.create(body, filedBy, filedByRole);
    }
    async getById(id) {
        return this.disputesService.getById(id);
    }
    async getByOrderId(orderId) {
        return this.disputesService.getByOrderId(orderId);
    }
    async getAll(status, category) {
        return this.disputesService.getAll({ status, category });
    }
    async providerResponse(body) {
        const providerId = 1;
        return this.disputesService.providerResponse(body, providerId);
    }
    async scheduleRevisit(body) {
        return this.disputesService.scheduleRevisit(body);
    }
    async resolve(body) {
        const resolvedBy = 1;
        return this.disputesService.resolve(body, resolvedBy);
    }
    async getStats() {
        return this.disputesService.getStats();
    }
};
exports.DisputesController = DisputesController;
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dispute_dto_1.CreateDisputeDto]),
    __metadata("design:returntype", Promise)
], DisputesController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], DisputesController.prototype, "getById", null);
__decorate([
    (0, common_1.Get)('order/:orderId'),
    __param(0, (0, common_1.Param)('orderId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], DisputesController.prototype, "getByOrderId", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('status')),
    __param(1, (0, common_1.Query)('category')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], DisputesController.prototype, "getAll", null);
__decorate([
    (0, common_1.Post)('respond'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dispute_dto_1.ProviderResponseDto]),
    __metadata("design:returntype", Promise)
], DisputesController.prototype, "providerResponse", null);
__decorate([
    (0, common_1.Post)('schedule-revisit'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dispute_dto_1.ScheduleRevisitDto]),
    __metadata("design:returntype", Promise)
], DisputesController.prototype, "scheduleRevisit", null);
__decorate([
    (0, common_1.Post)('resolve'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dispute_dto_1.ResolveDisputeDto]),
    __metadata("design:returntype", Promise)
], DisputesController.prototype, "resolve", null);
__decorate([
    (0, common_1.Get)('stats/overview'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], DisputesController.prototype, "getStats", null);
exports.DisputesController = DisputesController = __decorate([
    (0, common_1.Controller)('disputes'),
    __metadata("design:paramtypes", [disputes_service_1.DisputesService])
], DisputesController);
//# sourceMappingURL=disputes.controller.js.map