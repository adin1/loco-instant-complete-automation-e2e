"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OpensearchModule = void 0;
const common_1 = require("@nestjs/common");
const opensearch_service_1 = require("./opensearch.service");
const opensearch_controller_1 = require("./opensearch.controller");
const nestjs_opensearch_1 = require("nestjs-opensearch");
let OpensearchModule = class OpensearchModule {
};
exports.OpensearchModule = OpensearchModule;
exports.OpensearchModule = OpensearchModule = __decorate([
    (0, common_1.Module)({
        imports: [
            nestjs_opensearch_1.OpensearchModule.forRoot({
                node: process.env.OPENSEARCH_NODE || 'http://localhost:9200',
                auth: {
                    username: process.env.OPENSEARCH_USERNAME || 'admin',
                    password: process.env.OPENSEARCH_PASSWORD || 'admin',
                },
            })
        ],
        providers: [opensearch_service_1.OpensearchService],
        controllers: [opensearch_controller_1.OpensearchController]
    })
], OpensearchModule);
//# sourceMappingURL=opensearch.module.js.map