import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PgService } from '../../infra/db/pg.service';
import { 
  CreateDisputeDto, 
  UpdateDisputeDto, 
  ScheduleRevisitDto, 
  ResolveDisputeDto,
  ProviderResponseDto,
  DISPUTE_CATEGORIES 
} from './dto/dispute.dto';

@Injectable()
export class DisputesService {
  constructor(private pg: PgService) {}

  /**
   * Create a new dispute
   */
  async create(dto: CreateDisputeDto, filedBy: number, filedByRole: 'customer' | 'provider') {
    const { orderId, category, title, description, whatNotWorking, technicalDetails, evidenceUrls } = dto;

    // Verify order exists and is in correct status
    const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
    if (orderRows.length === 0) {
      throw new NotFoundException('Order not found');
    }
    const order = orderRows[0];

    // Only allow disputes for work_completed or confirmed orders
    if (!['work_completed', 'confirmed', 'funds_held'].includes(order.status)) {
      throw new BadRequestException(`Cannot create dispute for order in status: ${order.status}`);
    }

    // Check if user is party to this order
    if (filedByRole === 'customer' && order.customer_id !== filedBy) {
      throw new ForbiddenException('You are not the customer for this order');
    }

    // Get payment info
    const paymentRows = await this.pg.query('SELECT * FROM payments WHERE order_id = $1', [orderId]);
    const payment = paymentRows[0];

    // Create dispute
    const disputeRows = await this.pg.query(
      `INSERT INTO disputes (
        tenant_id, order_id, payment_id, filed_by, filed_by_role,
        category, title, description, what_not_working, technical_details, status
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'open'
      ) RETURNING *`,
      [
        order.tenant_id,
        orderId,
        payment?.id,
        filedBy,
        filedByRole,
        category,
        title,
        description,
        whatNotWorking,
        technicalDetails,
      ]
    );

    const dispute = disputeRows[0];

    // Update order status to disputed
    await this.pg.query(
      `UPDATE orders SET status = 'disputed' WHERE id = $1`,
      [orderId]
    );

    // Update payment status
    if (payment) {
      await this.pg.query(
        `UPDATE payments SET status = 'disputed' WHERE id = $1`,
        [payment.id]
      );
    }

    // Add evidence if provided
    if (evidenceUrls && evidenceUrls.length > 0) {
      for (const url of evidenceUrls) {
        await this.pg.query(
          `INSERT INTO order_evidence (
            tenant_id, order_id, uploaded_by, evidence_type, media_type, file_url
          ) VALUES (
            $1, $2, $3, 'dispute_evidence', 'image', $4
          )`,
          [order.tenant_id, orderId, filedBy, url]
        );
      }
    }

    // Send notifications
    await this.sendDisputeNotification(order, dispute, filedByRole);

    return dispute;
  }

  /**
   * Get dispute by ID
   */
  async getById(disputeId: number) {
    const rows = await this.pg.query(
      `SELECT d.*, 
        o.status as order_status,
        p.total_amount, p.status as payment_status,
        uc.email as customer_email,
        pr.display_name as provider_name
       FROM disputes d
       JOIN orders o ON o.id = d.order_id
       LEFT JOIN payments p ON p.id = d.payment_id
       JOIN users uc ON uc.id = o.customer_id
       LEFT JOIN providers pr ON pr.id = o.provider_id
       WHERE d.id = $1`,
      [disputeId]
    );

    if (rows.length === 0) {
      throw new NotFoundException('Dispute not found');
    }

    // Get evidence
    const evidence = await this.pg.query(
      `SELECT * FROM order_evidence WHERE order_id = $1 ORDER BY created_at`,
      [rows[0].order_id]
    );

    return {
      ...rows[0],
      evidence,
    };
  }

  /**
   * Get disputes for an order
   */
  async getByOrderId(orderId: number) {
    const rows = await this.pg.query(
      `SELECT * FROM disputes WHERE order_id = $1 ORDER BY created_at DESC`,
      [orderId]
    );
    return rows;
  }

  /**
   * Get all disputes (with filters)
   */
  async getAll(filters?: { status?: string; category?: string }) {
    let query = `
      SELECT d.*, 
        o.status as order_status,
        uc.email as customer_email,
        pr.display_name as provider_name
      FROM disputes d
      JOIN orders o ON o.id = d.order_id
      JOIN users uc ON uc.id = o.customer_id
      LEFT JOIN providers pr ON pr.id = o.provider_id
      WHERE 1=1
    `;
    const params: any[] = [];
    let paramIndex = 1;

    if (filters?.status) {
      query += ` AND d.status = $${paramIndex++}`;
      params.push(filters.status);
    }
    if (filters?.category) {
      query += ` AND d.category = $${paramIndex++}`;
      params.push(filters.category);
    }

    query += ' ORDER BY d.created_at DESC';

    return this.pg.query(query, params);
  }

  /**
   * Provider response to dispute
   */
  async providerResponse(dto: ProviderResponseDto, providerId: number) {
    const { disputeId, response, evidenceUrls, acceptRevisit } = dto;

    const dispute = await this.getById(disputeId);

    // Update dispute
    await this.pg.query(
      `UPDATE disputes 
       SET status = $1, updated_at = NOW()
       WHERE id = $2`,
      [acceptRevisit ? 'scheduled_revisit' : 'awaiting_response', disputeId]
    );

    // Add provider evidence
    if (evidenceUrls && evidenceUrls.length > 0) {
      const providerUserId = await this.getProviderUserId(providerId);
      for (const url of evidenceUrls) {
        await this.pg.query(
          `INSERT INTO order_evidence (
            tenant_id, order_id, uploaded_by, evidence_type, media_type, file_url, description
          ) VALUES (
            $1, $2, $3, 'dispute_evidence', 'image', $4, $5
          )`,
          [dispute.tenant_id, dispute.order_id, providerUserId, url, `Provider response: ${response.substring(0, 100)}`]
        );
      }
    }

    return { success: true, message: 'Response submitted' };
  }

  /**
   * Schedule revisit
   */
  async scheduleRevisit(dto: ScheduleRevisitDto) {
    const { disputeId, scheduledAt, cost = 0, notes } = dto;

    await this.pg.query(
      `UPDATE disputes 
       SET status = 'scheduled_revisit', 
           revisit_scheduled_at = $1,
           revisit_cost = $2,
           revisit_notes = $3,
           updated_at = NOW()
       WHERE id = $4`,
      [scheduledAt, cost, notes, disputeId]
    );

    return { success: true, message: 'Revisit scheduled' };
  }

  /**
   * Resolve dispute
   */
  async resolve(dto: ResolveDisputeDto, resolvedBy: number) {
    const { disputeId, resolution, refundAmount, resolutionNotes } = dto;

    const dispute = await this.getById(disputeId);

    // Update dispute
    await this.pg.query(
      `UPDATE disputes 
       SET status = $1, 
           resolution_notes = $2,
           resolution_amount = $3,
           resolved_by = $4,
           resolved_at = NOW(),
           updated_at = NOW()
       WHERE id = $5`,
      [resolution, resolutionNotes, refundAmount, resolvedBy, disputeId]
    );

    // Handle payment based on resolution
    if (dispute.payment_id) {
      switch (resolution) {
        case 'resolved_refund':
          // Full refund
          await this.pg.query(
            `UPDATE payments SET status = 'refunded', refunded_at = NOW() WHERE id = $1`,
            [dispute.payment_id]
          );
          await this.pg.query(
            `UPDATE orders SET status = 'refunded' WHERE id = $1`,
            [dispute.order_id]
          );
          break;

        case 'resolved_partial':
          // Partial refund - still release remaining to provider
          // This would involve splitting the payment
          break;

        case 'resolved_redo':
          // Work will be redone - payment stays held
          await this.pg.query(
            `UPDATE orders SET status = 'in_progress' WHERE id = $1`,
            [dispute.order_id]
          );
          break;

        case 'rejected':
          // Dispute rejected - release payment to provider
          await this.pg.query(
            `UPDATE payments SET status = 'released', released_at = NOW() WHERE id = $1`,
            [dispute.payment_id]
          );
          await this.pg.query(
            `UPDATE orders SET status = 'completed' WHERE id = $1`,
            [dispute.order_id]
          );
          break;
      }
    }

    return { success: true, message: `Dispute resolved as: ${resolution}` };
  }

  /**
   * Get dispute statistics
   */
  async getStats() {
    const stats = await this.pg.query(`
      SELECT 
        status,
        category,
        COUNT(*) as count
      FROM disputes
      GROUP BY status, category
    `);

    const byStatus: Record<string, number> = {};
    const byCategory: Record<string, number> = {};

    for (const row of stats) {
      byStatus[row.status] = (byStatus[row.status] || 0) + parseInt(row.count);
      byCategory[row.category] = (byCategory[row.category] || 0) + parseInt(row.count);
    }

    return { byStatus, byCategory };
  }

  /**
   * Helper: Get provider's user ID
   */
  private async getProviderUserId(providerId: number): Promise<number> {
    const rows = await this.pg.query('SELECT user_id FROM providers WHERE id = $1', [providerId]);
    return rows[0]?.user_id;
  }

  /**
   * Helper: Send dispute notification
   */
  private async sendDisputeNotification(order: any, dispute: any, filedByRole: string) {
    // Determine who to notify
    const notifyUserId = filedByRole === 'customer' 
      ? await this.getProviderUserId(order.provider_id)
      : order.customer_id;

    if (notifyUserId) {
      await this.pg.query(
        `INSERT INTO notifications (
          tenant_id, user_id, notification_type, title, body, data
        ) VALUES (
          $1, $2, 'dispute_opened', $3, $4, $5
        )`,
        [
          order.tenant_id,
          notifyUserId,
          'Reclamație nouă',
          `O reclamație a fost deschisă pentru comanda #${order.id}: ${dispute.title}`,
          JSON.stringify({ orderId: order.id, disputeId: dispute.id }),
        ]
      );
    }
  }
}

