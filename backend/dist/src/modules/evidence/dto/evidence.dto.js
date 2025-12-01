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
exports.UploadRequestDto = exports.GetEvidenceDto = exports.CreateEvidenceDto = exports.MEDIA_TYPES = exports.EVIDENCE_TYPES = void 0;
const class_validator_1 = require("class-validator");
exports.EVIDENCE_TYPES = [
    'before_work',
    'during_work',
    'after_work',
    'test_proof',
    'problem_report',
    'dispute_evidence',
];
exports.MEDIA_TYPES = ['image', 'video'];
class CreateEvidenceDto {
}
exports.CreateEvidenceDto = CreateEvidenceDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], CreateEvidenceDto.prototype, "orderId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsIn)(exports.EVIDENCE_TYPES),
    __metadata("design:type", String)
], CreateEvidenceDto.prototype, "evidenceType", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsIn)(exports.MEDIA_TYPES),
    __metadata("design:type", String)
], CreateEvidenceDto.prototype, "mediaType", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsUrl)(),
    __metadata("design:type", String)
], CreateEvidenceDto.prototype, "fileUrl", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsUrl)(),
    __metadata("design:type", String)
], CreateEvidenceDto.prototype, "thumbnailUrl", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], CreateEvidenceDto.prototype, "fileSizeBytes", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], CreateEvidenceDto.prototype, "durationSeconds", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateEvidenceDto.prototype, "description", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], CreateEvidenceDto.prototype, "locationLat", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], CreateEvidenceDto.prototype, "locationLng", void 0);
class GetEvidenceDto {
}
exports.GetEvidenceDto = GetEvidenceDto;
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsInt)(),
    __metadata("design:type", Number)
], GetEvidenceDto.prototype, "orderId", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsIn)(exports.EVIDENCE_TYPES),
    __metadata("design:type", String)
], GetEvidenceDto.prototype, "evidenceType", void 0);
class UploadRequestDto {
}
exports.UploadRequestDto = UploadRequestDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsPositive)(),
    __metadata("design:type", Number)
], UploadRequestDto.prototype, "orderId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsIn)(exports.EVIDENCE_TYPES),
    __metadata("design:type", String)
], UploadRequestDto.prototype, "evidenceType", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsIn)(exports.MEDIA_TYPES),
    __metadata("design:type", String)
], UploadRequestDto.prototype, "mediaType", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UploadRequestDto.prototype, "fileName", void 0);
__decorate([
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UploadRequestDto.prototype, "fileSize", void 0);
//# sourceMappingURL=evidence.dto.js.map