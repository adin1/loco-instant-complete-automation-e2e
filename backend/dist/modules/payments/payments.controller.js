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
exports.PaymentsController = void 0;
const common_1 = require("@nestjs/common");
const payments_service_1 = require("./payments.service");
const payment_dto_1 = require("./dto/payment.dto");
let PaymentsController = class PaymentsController {
    constructor(paymentsService) {
        this.paymentsService = paymentsService;
    }
    async createIntent(body) {
        return this.paymentsService.createIntent(body);
    }
    async authorize(body) {
        return this.paymentsService.authorize(body);
    }
    async capture(body) {
        return this.paymentsService.capture(body);
    }
    async releaseEscrow(body) {
        return this.paymentsService.releaseEscrow(body);
    }
    async refund(body) {
        return this.paymentsService.refund(body);
    }
    async getByOrderId(orderId) {
        return this.paymentsService.getPaymentByOrderId(orderId);
    }
    async getAll(status, orderId) {
        return this.paymentsService.getAllPayments({
            status,
            orderId: orderId ? parseInt(orderId, 10) : undefined,
        });
    }
    async processAutoRelease() {
        return this.paymentsService.processAutoRelease();
    }
    async confirm(body) {
        return this.paymentsService.confirm(body);
    }
};
exports.PaymentsController = PaymentsController;
__decorate([
    (0, common_1.Post)('intent'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [payment_dto_1.CreatePaymentIntentDto]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "createIntent", null);
__decorate([
    (0, common_1.Post)('authorize'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [payment_dto_1.AuthorizePaymentDto]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "authorize", null);
__decorate([
    (0, common_1.Post)('capture'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [payment_dto_1.CapturePaymentDto]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "capture", null);
__decorate([
    (0, common_1.Post)('release'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [payment_dto_1.ReleaseEscrowDto]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "releaseEscrow", null);
__decorate([
    (0, common_1.Post)('refund'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [payment_dto_1.RefundPaymentDto]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "refund", null);
__decorate([
    (0, common_1.Get)('order/:orderId'),
    __param(0, (0, common_1.Param)('orderId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "getByOrderId", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('status')),
    __param(1, (0, common_1.Query)('orderId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "getAll", null);
__decorate([
    (0, common_1.Post)('process-auto-release'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "processAutoRelease", null);
__decorate([
    (0, common_1.Post)('confirm'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "confirm", null);
exports.PaymentsController = PaymentsController = __decorate([
    (0, common_1.Controller)('payments'),
    __metadata("design:paramtypes", [payments_service_1.PaymentsService])
], PaymentsController);
//# sourceMappingURL=payments.controller.js.map