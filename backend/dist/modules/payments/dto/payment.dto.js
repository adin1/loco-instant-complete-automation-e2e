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
exports.PaymentWebhookDto = exports.RefundPaymentDto = exports.ReleaseEscrowDto = exports.CapturePaymentDto = exports.AuthorizePaymentDto = exports.CreatePaymentIntentDto = exports.PAYMENT_STATUSES = void 0;
const class_validator_1 = require("class-validator");
exports.PAYMENT_STATUSES = [
    'pending',
    'authorized',
    'advance_paid',
    'fully_paid',
    'held',
    'released',
    'refunded',
    'disputed',
    'failed',
];
class CreatePaymentIntentDto {
}
exports.CreatePaymentIntentDto = CreatePaymentIntentDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], CreatePaymentIntentDto.prototype, "orderId", void 0);
__decorate([
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], CreatePaymentIntentDto.prototype, "amount", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreatePaymentIntentDto.prototype, "currency", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], CreatePaymentIntentDto.prototype, "isAdvanceOnly", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.Max)(100),
    __metadata("design:type", Number)
], CreatePaymentIntentDto.prototype, "advancePercentage", void 0);
class AuthorizePaymentDto {
}
exports.AuthorizePaymentDto = AuthorizePaymentDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], AuthorizePaymentDto.prototype, "paymentId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AuthorizePaymentDto.prototype, "stripePaymentMethodId", void 0);
class CapturePaymentDto {
}
exports.CapturePaymentDto = CapturePaymentDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], CapturePaymentDto.prototype, "paymentId", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], CapturePaymentDto.prototype, "amount", void 0);
class ReleaseEscrowDto {
}
exports.ReleaseEscrowDto = ReleaseEscrowDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], ReleaseEscrowDto.prototype, "paymentId", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ReleaseEscrowDto.prototype, "notes", void 0);
class RefundPaymentDto {
}
exports.RefundPaymentDto = RefundPaymentDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], RefundPaymentDto.prototype, "paymentId", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], RefundPaymentDto.prototype, "amount", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], RefundPaymentDto.prototype, "reason", void 0);
class PaymentWebhookDto {
}
exports.PaymentWebhookDto = PaymentWebhookDto;
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], PaymentWebhookDto.prototype, "stripeSignature", void 0);
//# sourceMappingURL=payment.dto.js.map