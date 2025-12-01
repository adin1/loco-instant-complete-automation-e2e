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
exports.OpensearchService = void 0;
const common_1 = require("@nestjs/common");
const nestjs_opensearch_1 = require("nestjs-opensearch");
let OpensearchService = class OpensearchService {
    constructor(searchClient) {
        this.searchClient = searchClient;
    }
    async createDocument(index, id, document) {
        return await this.searchClient.index({
            index,
            id,
            body: document,
        });
    }
    async getDocument(index, id) {
        return await this.searchClient.get({
            index,
            id,
        });
    }
    async updateDocument(index, id, document) {
        return await this.searchClient.update({
            index,
            id,
            body: {
                doc: document,
            },
        });
    }
    async deleteDocument(index, id) {
        return await this.searchClient.delete({
            index,
            id,
        });
    }
    async searchDocuments(index, body) {
        return await this.searchClient.search({
            index,
            body,
        });
    }
};
exports.OpensearchService = OpensearchService;
exports.OpensearchService = OpensearchService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, nestjs_opensearch_1.InjectOpensearchClient)()),
    __metadata("design:paramtypes", [nestjs_opensearch_1.OpensearchClient])
], OpensearchService);
//# sourceMappingURL=opensearch.service.js.map