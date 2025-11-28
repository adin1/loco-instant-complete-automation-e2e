"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentsService = void 0;
const common_1 = require("@nestjs/common");
let PaymentsService = class PaymentsService {
    async createIntent(body) {
        var _a, _b;
        return {
            clientSecret: 'mock_client_secret',
            amount: (_a = body.amount) !== null && _a !== void 0 ? _a : 0,
            currency: (_b = body.currency) !== null && _b !== void 0 ? _b : 'EUR',
        };
    }
    async confirm(body) {
        var _a;
        return {
            success: true,
            paymentId: (_a = body.paymentId) !== null && _a !== void 0 ? _a : 'mock_payment_id',
        };
    }
};
exports.PaymentsService = PaymentsService;
exports.PaymentsService = PaymentsService = __decorate([
    (0, common_1.Injectable)()
], PaymentsService);
//# sourceMappingURL=payments.service.js.map