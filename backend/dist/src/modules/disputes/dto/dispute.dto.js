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
exports.ProviderResponseDto = exports.ResolveDisputeDto = exports.ScheduleRevisitDto = exports.UpdateDisputeDto = exports.CreateDisputeDto = exports.DISPUTE_STATUSES = exports.DISPUTE_CATEGORIES = void 0;
const class_validator_1 = require("class-validator");
exports.DISPUTE_CATEGORIES = [
    'work_not_completed',
    'poor_quality',
    'different_from_agreed',
    'damage_caused',
    'no_show',
    'overcharged',
    'payment_issue',
    'communication',
    'other',
];
exports.DISPUTE_STATUSES = [
    'open',
    'under_review',
    'awaiting_response',
    'scheduled_revisit',
    'resolved_refund',
    'resolved_partial',
    'resolved_redo',
    'rejected',
    'closed',
];
class CreateDisputeDto {
}
exports.CreateDisputeDto = CreateDisputeDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], CreateDisputeDto.prototype, "orderId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsIn)(exports.DISPUTE_CATEGORIES),
    __metadata("design:type", String)
], CreateDisputeDto.prototype, "category", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateDisputeDto.prototype, "title", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateDisputeDto.prototype, "description", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateDisputeDto.prototype, "whatNotWorking", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateDisputeDto.prototype, "technicalDetails", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], CreateDisputeDto.prototype, "evidenceUrls", void 0);
class UpdateDisputeDto {
}
exports.UpdateDisputeDto = UpdateDisputeDto;
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsIn)(exports.DISPUTE_STATUSES),
    __metadata("design:type", String)
], UpdateDisputeDto.prototype, "status", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateDisputeDto.prototype, "resolutionNotes", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UpdateDisputeDto.prototype, "resolutionAmount", void 0);
class ScheduleRevisitDto {
}
exports.ScheduleRevisitDto = ScheduleRevisitDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], ScheduleRevisitDto.prototype, "disputeId", void 0);
__decorate([
    (0, class_validator_1.IsDateString)(),
    __metadata("design:type", String)
], ScheduleRevisitDto.prototype, "scheduledAt", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], ScheduleRevisitDto.prototype, "cost", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ScheduleRevisitDto.prototype, "notes", void 0);
class ResolveDisputeDto {
}
exports.ResolveDisputeDto = ResolveDisputeDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], ResolveDisputeDto.prototype, "disputeId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsIn)(['resolved_refund', 'resolved_partial', 'resolved_redo', 'rejected']),
    __metadata("design:type", String)
], ResolveDisputeDto.prototype, "resolution", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], ResolveDisputeDto.prototype, "refundAmount", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ResolveDisputeDto.prototype, "resolutionNotes", void 0);
class ProviderResponseDto {
}
exports.ProviderResponseDto = ProviderResponseDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], ProviderResponseDto.prototype, "disputeId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ProviderResponseDto.prototype, "response", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], ProviderResponseDto.prototype, "evidenceUrls", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], ProviderResponseDto.prototype, "acceptRevisit", void 0);
//# sourceMappingURL=dispute.dto.js.map