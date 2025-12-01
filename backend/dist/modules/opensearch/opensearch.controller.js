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
exports.OpensearchController = void 0;
const common_1 = require("@nestjs/common");
const opensearch_service_1 = require("./opensearch.service");
const create_opensearch_dto_1 = require("./create-opensearch.dto");
let OpensearchController = class OpensearchController {
    constructor(opensearchService) {
        this.opensearchService = opensearchService;
    }
    async create(index, id, body) {
        return this.opensearchService.createDocument(index, id, body.document);
    }
    async read(index, id) {
        return this.opensearchService.getDocument(index, id);
    }
    async update(index, id, body) {
        return this.opensearchService.updateDocument(index, id, body.document);
    }
    async delete(index, id) {
        return this.opensearchService.deleteDocument(index, id);
    }
    async search(index, body) {
        return this.opensearchService.searchDocuments(index, body);
    }
};
exports.OpensearchController = OpensearchController;
__decorate([
    (0, common_1.Post)(':index/:id'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Param)('index')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, create_opensearch_dto_1.CreateOpensearchDto]),
    __metadata("design:returntype", Promise)
], OpensearchController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(':index/:id'),
    __param(0, (0, common_1.Param)('index')),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], OpensearchController.prototype, "read", null);
__decorate([
    (0, common_1.Put)(':index/:id'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Param)('index')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, create_opensearch_dto_1.CreateOpensearchDto]),
    __metadata("design:returntype", Promise)
], OpensearchController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':index/:id'),
    __param(0, (0, common_1.Param)('index')),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], OpensearchController.prototype, "delete", null);
__decorate([
    (0, common_1.Post)(':index/_search'),
    __param(0, (0, common_1.Param)('index')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], OpensearchController.prototype, "search", null);
exports.OpensearchController = OpensearchController = __decorate([
    (0, common_1.Controller)('opensearch'),
    __metadata("design:paramtypes", [opensearch_service_1.OpensearchService])
], OpensearchController);
//# sourceMappingURL=opensearch.controller.js.map