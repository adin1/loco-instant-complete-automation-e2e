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
exports.ReviewsController = void 0;
const common_1 = require("@nestjs/common");
const reviews_service_1 = require("./reviews.service");
const review_dto_1 = require("./dto/review.dto");
let ReviewsController = class ReviewsController {
    constructor(reviewsService) {
        this.reviewsService = reviewsService;
    }
    async create(body) {
        const raterId = 1;
        const raterRole = 'customer';
        return this.reviewsService.create(body, raterId, raterRole);
    }
    async respond(body) {
        const responderId = 1;
        return this.reviewsService.respond(body, responderId);
    }
    async getForUser(userId, limit, offset) {
        return this.reviewsService.getForUser(userId, {
            limit: limit ? parseInt(limit, 10) : undefined,
            offset: offset ? parseInt(offset, 10) : undefined,
        });
    }
    async getByOrderId(orderId) {
        return this.reviewsService.getByOrderId(orderId);
    }
    async findAll(minRating, hasResponse) {
        return this.reviewsService.findAll({
            minRating: minRating ? parseInt(minRating, 10) : undefined,
            hasResponse: hasResponse === 'true' ? true : hasResponse === 'false' ? false : undefined,
        });
    }
    async blockUser(body) {
        const blockerId = 1;
        const blockerRole = 'customer';
        return this.reviewsService.blockUser(body, blockerId, blockerRole);
    }
    async unblockUser(userId) {
        const blockerId = 1;
        return this.reviewsService.unblockUser(userId, blockerId);
    }
    async isBlocked(userId) {
        const currentUserId = 1;
        return this.reviewsService.isBlocked(currentUserId, userId);
    }
    async getBlockedUsers() {
        const blockerId = 1;
        return this.reviewsService.getBlockedUsers(blockerId);
    }
};
exports.ReviewsController = ReviewsController;
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [review_dto_1.CreateReviewDto]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "create", null);
__decorate([
    (0, common_1.Post)('respond'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [review_dto_1.RespondToReviewDto]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "respond", null);
__decorate([
    (0, common_1.Get)('user/:userId'),
    __param(0, (0, common_1.Param)('userId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Query)('limit')),
    __param(2, (0, common_1.Query)('offset')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, String, String]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "getForUser", null);
__decorate([
    (0, common_1.Get)('order/:orderId'),
    __param(0, (0, common_1.Param)('orderId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "getByOrderId", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('minRating')),
    __param(1, (0, common_1.Query)('hasResponse')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Post)('block'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [review_dto_1.BlockUserDto]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "blockUser", null);
__decorate([
    (0, common_1.Delete)('block/:userId'),
    __param(0, (0, common_1.Param)('userId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "unblockUser", null);
__decorate([
    (0, common_1.Get)('block/check/:userId'),
    __param(0, (0, common_1.Param)('userId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "isBlocked", null);
__decorate([
    (0, common_1.Get)('blocked'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "getBlockedUsers", null);
exports.ReviewsController = ReviewsController = __decorate([
    (0, common_1.Controller)('reviews'),
    __metadata("design:paramtypes", [reviews_service_1.ReviewsService])
], ReviewsController);
//# sourceMappingURL=reviews.controller.js.map