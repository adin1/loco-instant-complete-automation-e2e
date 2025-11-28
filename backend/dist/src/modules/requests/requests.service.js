"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.RequestsService = void 0;
const common_1 = require("@nestjs/common");
let RequestsService = class RequestsService {
    constructor() {
        this.requests = [];
    }
    async findAll() {
        return this.requests;
    }
    async create(body) {
        const request = { id: this.requests.length + 1, status: 'open', ...body };
        this.requests.push(request);
        return request;
    }
    async getById(id) {
        const numericId = Number(id);
        const req = this.requests.find((r) => r.id === numericId);
        if (!req)
            throw new common_1.NotFoundException('Request not found');
        return req;
    }
};
exports.RequestsService = RequestsService;
exports.RequestsService = RequestsService = __decorate([
    (0, common_1.Injectable)()
], RequestsService);
//# sourceMappingURL=requests.service.js.map