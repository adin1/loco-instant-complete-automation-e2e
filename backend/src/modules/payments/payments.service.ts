import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PgService } from '../../infra/db/pg.service';
import { 
  CreatePaymentIntentDto, 
  AuthorizePaymentDto, 
  CapturePaymentDto,
  ReleaseEscrowDto,
  RefundPaymentDto 
} from './dto/payment.dto';

@Injectable()
export class PaymentsService {
  // Default escrow release time (48 hours)
  private readonly AUTO_RELEASE_HOURS = 48;
  private readonly PLATFORM_FEE_PERCENT = 10; // 10% platform fee
  private readonly DEFAULT_ADVANCE_PERCENT = 30; // 30% advance

  constructor(private pg: PgService) {}

  /**
   * 1. CREATE PAYMENT INTENT
   * Creates a payment record and (mock) Stripe payment intent
   */
  async createIntent(dto: CreatePaymentIntentDto) {
    const { orderId, amount, currency = 'RON', isAdvanceOnly, advancePercentage = this.DEFAULT_ADVANCE_PERCENT } = dto;

    // Get order
    const orderRows = await this.pg.query(
      'SELECT * FROM orders WHERE id = $1',
      [orderId]
    );
    if (orderRows.length === 0) {
      throw new NotFoundException('Order not found');
    }
    const order = orderRows[0];

    // Calculate amounts
    const advanceAmount = isAdvanceOnly ? Math.round(amount * advancePercentage / 100) : amount;
    const remainingAmount = amount - advanceAmount;
    const platformFee = Math.round(amount * this.PLATFORM_FEE_PERCENT / 100);

    // Create payment record
    const paymentRows = await this.pg.query(
      `INSERT INTO payments (
        tenant_id, order_id, customer_id, provider_id,
        total_amount, advance_amount, remaining_amount, platform_fee, currency,
        status
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, 'pending'
      ) RETURNING *`,
      [
        order.tenant_id,
        orderId,
        order.customer_id,
        order.provider_id,
        amount,
        advanceAmount,
        remainingAmount,
        platformFee,
        currency,
      ]
    );

    const payment = paymentRows[0];

    // TODO: Replace with real Stripe integration
    // const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    // const paymentIntent = await stripe.paymentIntents.create({
    //   amount: advanceAmount * 100, // Stripe uses cents
    //   currency: currency.toLowerCase(),
    //   capture_method: 'manual', // For pre-authorization
    //   metadata: { orderId, paymentId: payment.id }
    // });

    const mockPaymentIntentId = `pi_mock_${Date.now()}_${payment.id}`;

    // Update with Stripe ID
    await this.pg.query(
      `UPDATE payments SET stripe_payment_intent_id = $1 WHERE id = $2`,
      [mockPaymentIntentId, payment.id]
    );

    return {
      paymentId: payment.id,
      clientSecret: `${mockPaymentIntentId}_secret_mock`,
      amount: advanceAmount,
      totalAmount: amount,
      remainingAmount,
      currency,
      status: 'pending',
      isAdvanceOnly,
    };
  }

  /**
   * 2. AUTHORIZE PAYMENT (Pre-auth card)
   * Blocks the amount on card without charging
   */
  async authorize(dto: AuthorizePaymentDto) {
    const { paymentId, stripePaymentMethodId } = dto;

    const paymentRows = await this.pg.query(
      'SELECT * FROM payments WHERE id = $1',
      [paymentId]
    );
    if (paymentRows.length === 0) {
      throw new NotFoundException('Payment not found');
    }
    const payment = paymentRows[0];

    if (payment.status !== 'pending') {
      throw new BadRequestException(`Cannot authorize payment in status: ${payment.status}`);
    }

    // TODO: Real Stripe authorization
    // const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    // await stripe.paymentIntents.confirm(payment.stripe_payment_intent_id, {
    //   payment_method: stripePaymentMethodId,
    // });

    // Update payment status
    await this.pg.query(
      `UPDATE payments 
       SET status = 'authorized', authorized_at = NOW() 
       WHERE id = $1`,
      [paymentId]
    );

    // Update order status
    await this.pg.query(
      `UPDATE orders SET status = 'funds_held' WHERE id = $1`,
      [payment.order_id]
    );

    // Log status change
    await this.logStatusChange(payment.order_id, 'pending', 'funds_held', null, 'system');

    return {
      success: true,
      paymentId,
      status: 'authorized',
      message: 'Fondurile au fost blocate pe card',
    };
  }

  /**
   * 3. CAPTURE PAYMENT (Charge the card)
   * Called when work is completed and confirmed
   */
  async capture(dto: CapturePaymentDto) {
    const { paymentId, amount } = dto;

    const paymentRows = await this.pg.query(
      'SELECT * FROM payments WHERE id = $1',
      [paymentId]
    );
    if (paymentRows.length === 0) {
      throw new NotFoundException('Payment not found');
    }
    const payment = paymentRows[0];

    if (!['authorized', 'advance_paid'].includes(payment.status)) {
      throw new BadRequestException(`Cannot capture payment in status: ${payment.status}`);
    }

    const captureAmount = amount ?? payment.advance_amount;

    // TODO: Real Stripe capture
    // const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    // await stripe.paymentIntents.capture(payment.stripe_payment_intent_id, {
    //   amount_to_capture: captureAmount * 100,
    // });

    const mockChargeId = `ch_mock_${Date.now()}_${paymentId}`;

    // Update payment status
    const newStatus = payment.remaining_amount > 0 ? 'advance_paid' : 'held';
    await this.pg.query(
      `UPDATE payments 
       SET status = $1, stripe_charge_id = $2, advance_paid_at = NOW(), held_at = NOW()
       WHERE id = $3`,
      [newStatus, mockChargeId, paymentId]
    );

    return {
      success: true,
      paymentId,
      status: newStatus,
      capturedAmount: captureAmount,
      message: 'Plata a fost procesată și fondurile sunt în escrow',
    };
  }

  /**
   * 4. HOLD IN ESCROW
   * Called when provider marks work as completed
   */
  async holdInEscrow(orderId: number, providerId: number) {
    const paymentRows = await this.pg.query(
      'SELECT * FROM payments WHERE order_id = $1',
      [orderId]
    );
    if (paymentRows.length === 0) {
      throw new NotFoundException('Payment not found for order');
    }
    const payment = paymentRows[0];

    // Calculate auto-release time
    const autoReleaseAt = new Date();
    autoReleaseAt.setHours(autoReleaseAt.getHours() + this.AUTO_RELEASE_HOURS);

    // Update payment
    await this.pg.query(
      `UPDATE payments 
       SET status = 'held', held_at = NOW(), auto_release_at = $1
       WHERE id = $2`,
      [autoReleaseAt.toISOString(), payment.id]
    );

    // Schedule auto-release task
    await this.pg.query(
      `INSERT INTO scheduled_tasks (
        tenant_id, task_type, reference_type, reference_id, scheduled_for, payload
      ) VALUES (
        $1, 'auto_release_payment', 'payment', $2, $3, $4
      )`,
      [
        payment.tenant_id,
        payment.id,
        autoReleaseAt.toISOString(),
        JSON.stringify({ orderId, providerId }),
      ]
    );

    return {
      success: true,
      paymentId: payment.id,
      autoReleaseAt,
      hoursUntilRelease: this.AUTO_RELEASE_HOURS,
    };
  }

  /**
   * 5. RELEASE ESCROW TO PROVIDER
   * Called when customer confirms or timeout expires
   */
  async releaseEscrow(dto: ReleaseEscrowDto) {
    const { paymentId, notes } = dto;

    const paymentRows = await this.pg.query(
      'SELECT * FROM payments WHERE id = $1',
      [paymentId]
    );
    if (paymentRows.length === 0) {
      throw new NotFoundException('Payment not found');
    }
    const payment = paymentRows[0];

    if (payment.status !== 'held') {
      throw new BadRequestException(`Cannot release payment in status: ${payment.status}`);
    }

    // TODO: Real Stripe transfer to provider
    // const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    // const providerAmount = payment.total_amount - payment.platform_fee;
    // const transfer = await stripe.transfers.create({
    //   amount: providerAmount * 100,
    //   currency: payment.currency.toLowerCase(),
    //   destination: providerStripeAccountId,
    //   transfer_group: `order_${payment.order_id}`,
    // });

    const mockTransferId = `tr_mock_${Date.now()}_${paymentId}`;
    const providerAmount = payment.total_amount - payment.platform_fee;

    // Update payment
    await this.pg.query(
      `UPDATE payments 
       SET status = 'released', released_at = NOW(), stripe_transfer_id = $1
       WHERE id = $2`,
      [mockTransferId, paymentId]
    );

    // Update order status
    await this.pg.query(
      `UPDATE orders SET status = 'completed' WHERE id = $1`,
      [payment.order_id]
    );

    // Cancel any pending auto-release tasks
    await this.pg.query(
      `UPDATE scheduled_tasks 
       SET status = 'cancelled' 
       WHERE reference_type = 'payment' AND reference_id = $1 AND status = 'pending'`,
      [paymentId]
    );

    // Log status change
    await this.logStatusChange(payment.order_id, 'work_completed', 'completed', null, 'system');

    return {
      success: true,
      paymentId,
      status: 'released',
      providerAmount,
      platformFee: payment.platform_fee,
      message: 'Fondurile au fost transferate către prestator',
      notes,
    };
  }

  /**
   * 6. REFUND PAYMENT
   * Called when dispute is resolved in customer's favor
   */
  async refund(dto: RefundPaymentDto) {
    const { paymentId, amount, reason } = dto;

    const paymentRows = await this.pg.query(
      'SELECT * FROM payments WHERE id = $1',
      [paymentId]
    );
    if (paymentRows.length === 0) {
      throw new NotFoundException('Payment not found');
    }
    const payment = paymentRows[0];

    if (!['held', 'advance_paid', 'fully_paid'].includes(payment.status)) {
      throw new BadRequestException(`Cannot refund payment in status: ${payment.status}`);
    }

    const refundAmount = amount ?? payment.total_amount;

    // TODO: Real Stripe refund
    // const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    // await stripe.refunds.create({
    //   charge: payment.stripe_charge_id,
    //   amount: refundAmount * 100,
    //   reason: 'requested_by_customer',
    // });

    // Update payment
    await this.pg.query(
      `UPDATE payments 
       SET status = 'refunded', refunded_at = NOW()
       WHERE id = $1`,
      [paymentId]
    );

    // Update order status
    await this.pg.query(
      `UPDATE orders SET status = 'refunded' WHERE id = $1`,
      [payment.order_id]
    );

    // Cancel any pending tasks
    await this.pg.query(
      `UPDATE scheduled_tasks 
       SET status = 'cancelled' 
       WHERE reference_type = 'payment' AND reference_id = $1 AND status = 'pending'`,
      [paymentId]
    );

    return {
      success: true,
      paymentId,
      status: 'refunded',
      refundedAmount: refundAmount,
      reason,
      message: 'Suma a fost rambursată către client',
    };
  }

  /**
   * 7. GET PAYMENT STATUS
   */
  async getPaymentByOrderId(orderId: number) {
    const rows = await this.pg.query(
      `SELECT p.*, 
        EXTRACT(EPOCH FROM (p.auto_release_at - NOW())) / 3600 as hours_until_release,
        o.status as order_status
       FROM payments p
       JOIN orders o ON o.id = p.order_id
       WHERE p.order_id = $1`,
      [orderId]
    );
    
    if (rows.length === 0) {
      return null;
    }

    return rows[0];
  }

  /**
   * 8. GET ALL PAYMENTS (Admin)
   */
  async getAllPayments(filters?: { status?: string; orderId?: number }) {
    let query = 'SELECT * FROM payments WHERE 1=1';
    const params: any[] = [];
    let paramIndex = 1;

    if (filters?.status) {
      query += ` AND status = $${paramIndex++}`;
      params.push(filters.status);
    }
    if (filters?.orderId) {
      query += ` AND order_id = $${paramIndex++}`;
      params.push(filters.orderId);
    }

    query += ' ORDER BY created_at DESC';

    return this.pg.query(query, params);
  }

  /**
   * 9. PROCESS AUTO-RELEASE (Called by cron)
   */
  async processAutoRelease() {
    const pendingTasks = await this.pg.query(
      `SELECT st.*, p.id as payment_id, p.status as payment_status
       FROM scheduled_tasks st
       JOIN payments p ON p.id = st.reference_id
       WHERE st.task_type = 'auto_release_payment'
         AND st.status = 'pending'
         AND st.scheduled_for <= NOW()
         AND p.status = 'held'`
    );

    const results = [];
    for (const task of pendingTasks) {
      try {
        await this.releaseEscrow({ paymentId: task.payment_id });
        
        // Mark task as executed
        await this.pg.query(
          `UPDATE scheduled_tasks 
           SET status = 'executed', executed_at = NOW(), result = $1
           WHERE id = $2`,
          [JSON.stringify({ success: true }), task.id]
        );

        results.push({ taskId: task.id, success: true });
      } catch (error) {
        await this.pg.query(
          `UPDATE scheduled_tasks 
           SET status = 'failed', result = $1
           WHERE id = $2`,
          [JSON.stringify({ error: error.message }), task.id]
        );
        results.push({ taskId: task.id, success: false, error: error.message });
      }
    }

    return { processed: results.length, results };
  }

  /**
   * Helper: Log order status change
   */
  private async logStatusChange(
    orderId: number,
    oldStatus: string,
    newStatus: string,
    changedBy: number | null,
    changedByRole: string
  ) {
    await this.pg.query(
      `INSERT INTO order_status_history (
        tenant_id, order_id, old_status, new_status, changed_by, changed_by_role
      ) SELECT tenant_id, $1, $2, $3, $4, $5 FROM orders WHERE id = $1`,
      [orderId, oldStatus, newStatus, changedBy, changedByRole]
    );
  }

  // Legacy methods for backwards compatibility
  async createPaymentIntent(body: any) {
    return this.createIntent({
      orderId: body.orderId,
      amount: body.amount ?? 100,
      currency: body.currency ?? 'RON',
    });
  }

  async confirm(body: any) {
    if (body.paymentId) {
      return this.authorize({
        paymentId: parseInt(body.paymentId, 10),
        stripePaymentMethodId: body.paymentMethodId ?? 'mock_pm',
      });
    }
    return { success: true, paymentId: body.paymentId ?? 'mock_payment_id' };
  }
}
