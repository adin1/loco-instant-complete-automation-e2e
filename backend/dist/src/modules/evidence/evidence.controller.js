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
exports.EvidenceController = void 0;
const common_1 = require("@nestjs/common");
const evidence_service_1 = require("./evidence.service");
const evidence_dto_1 = require("./dto/evidence.dto");
let EvidenceController = class EvidenceController {
    constructor(evidenceService) {
        this.evidenceService = evidenceService;
    }
    async create(body) {
        const uploadedBy = 1;
        return this.evidenceService.create(body, uploadedBy);
    }
    async getUploadUrl(body) {
        return this.evidenceService.getUploadUrl(body);
    }
    async getByOrderId(orderId) {
        return this.evidenceService.getByOrderId(orderId);
    }
    async getByType(orderId, type) {
        return this.evidenceService.getByType(orderId, type);
    }
    async checkRequired(orderId) {
        return this.evidenceService.checkRequiredEvidence(orderId);
    }
    async getForDispute(orderId) {
        return this.evidenceService.getForDispute(orderId);
    }
    async delete(id) {
        return this.evidenceService.delete(id);
    }
};
exports.EvidenceController = EvidenceController;
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [evidence_dto_1.CreateEvidenceDto]),
    __metadata("design:returntype", Promise)
], EvidenceController.prototype, "create", null);
__decorate([
    (0, common_1.Post)('upload-url'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [evidence_dto_1.UploadRequestDto]),
    __metadata("design:returntype", Promise)
], EvidenceController.prototype, "getUploadUrl", null);
__decorate([
    (0, common_1.Get)('order/:orderId'),
    __param(0, (0, common_1.Param)('orderId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], EvidenceController.prototype, "getByOrderId", null);
__decorate([
    (0, common_1.Get)('order/:orderId/type/:type'),
    __param(0, (0, common_1.Param)('orderId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Param)('type')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, String]),
    __metadata("design:returntype", Promise)
], EvidenceController.prototype, "getByType", null);
__decorate([
    (0, common_1.Get)('order/:orderId/check'),
    __param(0, (0, common_1.Param)('orderId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], EvidenceController.prototype, "checkRequired", null);
__decorate([
    (0, common_1.Get)('order/:orderId/dispute'),
    __param(0, (0, common_1.Param)('orderId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], EvidenceController.prototype, "getForDispute", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], EvidenceController.prototype, "delete", null);
exports.EvidenceController = EvidenceController = __decorate([
    (0, common_1.Controller)('evidence'),
    __metadata("design:paramtypes", [evidence_service_1.EvidenceService])
], EvidenceController);
//# sourceMappingURL=evidence.controller.js.map