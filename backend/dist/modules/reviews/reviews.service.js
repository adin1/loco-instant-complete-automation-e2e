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
exports.ReviewsService = void 0;
const common_1 = require("@nestjs/common");
const pg_service_1 = require("../../infra/db/pg.service");
let ReviewsService = class ReviewsService {
    constructor(pg) {
        this.pg = pg;
    }
    async create(dto, raterId, raterRole) {
        var _a;
        const { orderId, overallRating, qualityRating, punctualityRating, communicationRating, reviewText, isPublic = true } = dto;
        const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
        if (orderRows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        const order = orderRows[0];
        if (!['completed', 'confirmed'].includes(order.status)) {
            throw new common_1.BadRequestException('Can only review completed orders');
        }
        let ratedId;
        if (raterRole === 'customer') {
            if (order.customer_id !== raterId) {
                throw new common_1.BadRequestException('You are not the customer for this order');
            }
            const providerRows = await this.pg.query('SELECT user_id FROM providers WHERE id = $1', [order.provider_id]);
            ratedId = (_a = providerRows[0]) === null || _a === void 0 ? void 0 : _a.user_id;
        }
        else {
            ratedId = order.customer_id;
        }
        if (!ratedId) {
            throw new common_1.BadRequestException('Cannot determine who to rate');
        }
        const existingRows = await this.pg.query('SELECT id FROM user_ratings WHERE order_id = $1 AND rater_id = $2', [orderId, raterId]);
        if (existingRows.length > 0) {
            throw new common_1.ConflictException('You have already reviewed this order');
        }
        const rows = await this.pg.query(`INSERT INTO user_ratings (
        tenant_id, order_id, rater_id, rated_id, rater_role,
        overall_rating, quality_rating, punctuality_rating, communication_rating,
        review_text, is_public
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
      ) RETURNING *`, [
            order.tenant_id,
            orderId,
            raterId,
            ratedId,
            raterRole,
            overallRating,
            qualityRating,
            punctualityRating,
            communicationRating,
            reviewText,
            isPublic,
        ]);
        if (raterRole === 'customer') {
            await this.updateProviderRating(order.provider_id);
        }
        return rows[0];
    }
    async respond(dto, responderId) {
        const { reviewId, responseText } = dto;
        const reviewRows = await this.pg.query('SELECT * FROM user_ratings WHERE id = $1', [reviewId]);
        if (reviewRows.length === 0) {
            throw new common_1.NotFoundException('Review not found');
        }
        const review = reviewRows[0];
        if (review.rated_id !== responderId) {
            throw new common_1.BadRequestException('You can only respond to reviews about you');
        }
        if (review.response_text) {
            throw new common_1.BadRequestException('You have already responded to this review');
        }
        await this.pg.query(`UPDATE user_ratings SET response_text = $1, response_at = NOW() WHERE id = $2`, [responseText, reviewId]);
        return { success: true, message: 'Response added' };
    }
    async getForUser(userId, options) {
        const { limit = 20, offset = 0, publicOnly = true } = options !== null && options !== void 0 ? options : {};
        let query = `
      SELECT ur.*, 
        o.status as order_status,
        uc.email as rater_email,
        s.name as service_name
      FROM user_ratings ur
      JOIN orders o ON o.id = ur.order_id
      JOIN users uc ON uc.id = ur.rater_id
      LEFT JOIN services s ON s.id = o.service_id
      WHERE ur.rated_id = $1
    `;
        if (publicOnly) {
            query += ' AND ur.is_public = TRUE';
        }
        query += ' ORDER BY ur.created_at DESC LIMIT $2 OFFSET $3';
        const rows = await this.pg.query(query, [userId, limit, offset]);
        const statsRows = await this.pg.query(`
      SELECT 
        COUNT(*) as total_reviews,
        AVG(overall_rating) as avg_rating,
        AVG(quality_rating) as avg_quality,
        AVG(punctuality_rating) as avg_punctuality,
        AVG(communication_rating) as avg_communication
      FROM user_ratings
      WHERE rated_id = $1
    `, [userId]);
        return {
            reviews: rows,
            stats: statsRows[0],
        };
    }
    async getByOrderId(orderId) {
        const rows = await this.pg.query(`SELECT ur.*, u.email as rater_email
       FROM user_ratings ur
       JOIN users u ON u.id = ur.rater_id
       WHERE ur.order_id = $1`, [orderId]);
        return rows;
    }
    async blockUser(dto, blockerId, blockerRole) {
        var _a, _b;
        const { userId, reason, notes } = dto;
        const existingRows = await this.pg.query('SELECT id FROM user_blocks WHERE blocker_id = $1 AND blocked_id = $2', [blockerId, userId]);
        if (existingRows.length > 0) {
            throw new common_1.ConflictException('User already blocked');
        }
        const blockerRows = await this.pg.query('SELECT tenant_id FROM users WHERE id = $1', [blockerId]);
        const tenantId = (_b = (_a = blockerRows[0]) === null || _a === void 0 ? void 0 : _a.tenant_id) !== null && _b !== void 0 ? _b : 1;
        const rows = await this.pg.query(`INSERT INTO user_blocks (tenant_id, blocker_id, blocked_id, blocker_role, reason, notes)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`, [tenantId, blockerId, userId, blockerRole, reason, notes]);
        return rows[0];
    }
    async unblockUser(blockedId, blockerId) {
        const rows = await this.pg.query('DELETE FROM user_blocks WHERE blocker_id = $1 AND blocked_id = $2 RETURNING *', [blockerId, blockedId]);
        if (rows.length === 0) {
            throw new common_1.NotFoundException('Block not found');
        }
        return { success: true };
    }
    async isBlocked(userId1, userId2) {
        const rows = await this.pg.query(`SELECT id FROM user_blocks 
       WHERE (blocker_id = $1 AND blocked_id = $2) 
          OR (blocker_id = $2 AND blocked_id = $1)`, [userId1, userId2]);
        return { isBlocked: rows.length > 0 };
    }
    async getBlockedUsers(blockerId) {
        const rows = await this.pg.query(`SELECT ub.*, u.email as blocked_email
       FROM user_blocks ub
       JOIN users u ON u.id = ub.blocked_id
       WHERE ub.blocker_id = $1
       ORDER BY ub.created_at DESC`, [blockerId]);
        return rows;
    }
    async findAll(filters) {
        let query = `
      SELECT ur.*, 
        rater.email as rater_email,
        rated.email as rated_email
      FROM user_ratings ur
      JOIN users rater ON rater.id = ur.rater_id
      JOIN users rated ON rated.id = ur.rated_id
      WHERE 1=1
    `;
        const params = [];
        if (filters === null || filters === void 0 ? void 0 : filters.minRating) {
            query += ` AND ur.overall_rating >= $${params.length + 1}`;
            params.push(filters.minRating);
        }
        if ((filters === null || filters === void 0 ? void 0 : filters.hasResponse) !== undefined) {
            if (filters.hasResponse) {
                query += ' AND ur.response_text IS NOT NULL';
            }
            else {
                query += ' AND ur.response_text IS NULL';
            }
        }
        query += ' ORDER BY ur.created_at DESC';
        return this.pg.query(query, params);
    }
    async updateProviderRating(providerId) {
        await this.pg.query(`
      UPDATE providers p
      SET rating_avg = (
        SELECT COALESCE(AVG(ur.overall_rating), 0)
        FROM user_ratings ur
        JOIN orders o ON o.id = ur.order_id
        WHERE o.provider_id = p.id AND ur.rater_role = 'customer'
      ),
      rating_count = (
        SELECT COUNT(*)
        FROM user_ratings ur
        JOIN orders o ON o.id = ur.order_id
        WHERE o.provider_id = p.id AND ur.rater_role = 'customer'
      )
      WHERE p.id = $1
    `, [providerId]);
    }
};
exports.ReviewsService = ReviewsService;
exports.ReviewsService = ReviewsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService])
], ReviewsService);
//# sourceMappingURL=reviews.service.js.map