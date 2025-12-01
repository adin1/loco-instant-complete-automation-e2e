import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { PgService } from '../../infra/db/pg.service';
import { CreateReviewDto, RespondToReviewDto, BlockUserDto } from './dto/review.dto';

@Injectable()
export class ReviewsService {
  constructor(private pg: PgService) {}

  /**
   * Create a review
   */
  async create(dto: CreateReviewDto, raterId: number, raterRole: 'customer' | 'provider') {
    const { orderId, overallRating, qualityRating, punctualityRating, communicationRating, reviewText, isPublic = true } = dto;

    // Get order
    const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
    if (orderRows.length === 0) {
      throw new NotFoundException('Order not found');
    }
    const order = orderRows[0];

    // Verify order is completed
    if (!['completed', 'confirmed'].includes(order.status)) {
      throw new BadRequestException('Can only review completed orders');
    }

    // Determine who is being rated
    let ratedId: number;
    if (raterRole === 'customer') {
      // Customer rates provider
      if (order.customer_id !== raterId) {
        throw new BadRequestException('You are not the customer for this order');
      }
      const providerRows = await this.pg.query('SELECT user_id FROM providers WHERE id = $1', [order.provider_id]);
      ratedId = providerRows[0]?.user_id;
    } else {
      // Provider rates customer
      ratedId = order.customer_id;
    }

    if (!ratedId) {
      throw new BadRequestException('Cannot determine who to rate');
    }

    // Check if already reviewed
    const existingRows = await this.pg.query(
      'SELECT id FROM user_ratings WHERE order_id = $1 AND rater_id = $2',
      [orderId, raterId]
    );
    if (existingRows.length > 0) {
      throw new ConflictException('You have already reviewed this order');
    }

    // Create review
    const rows = await this.pg.query(
      `INSERT INTO user_ratings (
        tenant_id, order_id, rater_id, rated_id, rater_role,
        overall_rating, quality_rating, punctuality_rating, communication_rating,
        review_text, is_public
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
      ) RETURNING *`,
      [
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
      ]
    );

    // Update provider's average rating if customer reviewed
    if (raterRole === 'customer') {
      await this.updateProviderRating(order.provider_id);
    }

    return rows[0];
  }

  /**
   * Respond to a review (provider only)
   */
  async respond(dto: RespondToReviewDto, responderId: number) {
    const { reviewId, responseText } = dto;

    // Verify the review exists and responder is the rated party
    const reviewRows = await this.pg.query(
      'SELECT * FROM user_ratings WHERE id = $1',
      [reviewId]
    );
    if (reviewRows.length === 0) {
      throw new NotFoundException('Review not found');
    }
    const review = reviewRows[0];

    if (review.rated_id !== responderId) {
      throw new BadRequestException('You can only respond to reviews about you');
    }

    if (review.response_text) {
      throw new BadRequestException('You have already responded to this review');
    }

    // Update with response
    await this.pg.query(
      `UPDATE user_ratings SET response_text = $1, response_at = NOW() WHERE id = $2`,
      [responseText, reviewId]
    );

    return { success: true, message: 'Response added' };
  }

  /**
   * Get reviews for a user
   */
  async getForUser(userId: number, options?: { limit?: number; offset?: number; publicOnly?: boolean }) {
    const { limit = 20, offset = 0, publicOnly = true } = options ?? {};

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

    // Get stats
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

  /**
   * Get reviews by order
   */
  async getByOrderId(orderId: number) {
    const rows = await this.pg.query(
      `SELECT ur.*, u.email as rater_email
       FROM user_ratings ur
       JOIN users u ON u.id = ur.rater_id
       WHERE ur.order_id = $1`,
      [orderId]
    );
    return rows;
  }

  /**
   * Block a user
   */
  async blockUser(dto: BlockUserDto, blockerId: number, blockerRole: 'customer' | 'provider') {
    const { userId, reason, notes } = dto;

    // Check if already blocked
    const existingRows = await this.pg.query(
      'SELECT id FROM user_blocks WHERE blocker_id = $1 AND blocked_id = $2',
      [blockerId, userId]
    );
    if (existingRows.length > 0) {
      throw new ConflictException('User already blocked');
    }

    // Get blocker's tenant
    const blockerRows = await this.pg.query('SELECT tenant_id FROM users WHERE id = $1', [blockerId]);
    const tenantId = blockerRows[0]?.tenant_id ?? 1;

    // Create block
    const rows = await this.pg.query(
      `INSERT INTO user_blocks (tenant_id, blocker_id, blocked_id, blocker_role, reason, notes)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [tenantId, blockerId, userId, blockerRole, reason, notes]
    );

    return rows[0];
  }

  /**
   * Unblock a user
   */
  async unblockUser(blockedId: number, blockerId: number) {
    const rows = await this.pg.query(
      'DELETE FROM user_blocks WHERE blocker_id = $1 AND blocked_id = $2 RETURNING *',
      [blockerId, blockedId]
    );

    if (rows.length === 0) {
      throw new NotFoundException('Block not found');
    }

    return { success: true };
  }

  /**
   * Check if user is blocked
   */
  async isBlocked(userId1: number, userId2: number) {
    const rows = await this.pg.query(
      `SELECT id FROM user_blocks 
       WHERE (blocker_id = $1 AND blocked_id = $2) 
          OR (blocker_id = $2 AND blocked_id = $1)`,
      [userId1, userId2]
    );
    return { isBlocked: rows.length > 0 };
  }

  /**
   * Get blocked users list
   */
  async getBlockedUsers(blockerId: number) {
    const rows = await this.pg.query(
      `SELECT ub.*, u.email as blocked_email
       FROM user_blocks ub
       JOIN users u ON u.id = ub.blocked_id
       WHERE ub.blocker_id = $1
       ORDER BY ub.created_at DESC`,
      [blockerId]
    );
    return rows;
  }

  /**
   * Get all reviews (admin)
   */
  async findAll(filters?: { minRating?: number; hasResponse?: boolean }) {
    let query = `
      SELECT ur.*, 
        rater.email as rater_email,
        rated.email as rated_email
      FROM user_ratings ur
      JOIN users rater ON rater.id = ur.rater_id
      JOIN users rated ON rated.id = ur.rated_id
      WHERE 1=1
    `;
    const params: any[] = [];

    if (filters?.minRating) {
      query += ` AND ur.overall_rating >= $${params.length + 1}`;
      params.push(filters.minRating);
    }
    if (filters?.hasResponse !== undefined) {
      if (filters.hasResponse) {
        query += ' AND ur.response_text IS NOT NULL';
      } else {
        query += ' AND ur.response_text IS NULL';
      }
    }

    query += ' ORDER BY ur.created_at DESC';

    return this.pg.query(query, params);
  }

  /**
   * Update provider's average rating
   */
  private async updateProviderRating(providerId: number) {
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
}
