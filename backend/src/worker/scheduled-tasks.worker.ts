import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PgService } from '../infra/db/pg.service';
import { PaymentsService } from '../modules/payments/payments.service';

@Injectable()
export class ScheduledTasksWorker {
  private readonly logger = new Logger(ScheduledTasksWorker.name);

  constructor(
    private pg: PgService,
    private paymentsService: PaymentsService,
  ) {}

  /**
   * Process auto-release payments every 5 minutes
   */
  @Cron(CronExpression.EVERY_5_MINUTES)
  async processAutoReleasePayments() {
    this.logger.log('🔄 Processing auto-release payments...');

    try {
      const result = await this.paymentsService.processAutoRelease();
      
      if (result.processed > 0) {
        this.logger.log(`✅ Processed ${result.processed} auto-release payments`);
      }
    } catch (error) {
      this.logger.error('❌ Error processing auto-release payments:', error);
    }
  }

  /**
   * Send reminder notifications for pending confirmations
   * Runs every hour
   */
  @Cron(CronExpression.EVERY_HOUR)
  async sendConfirmationReminders() {
    this.logger.log('🔔 Sending confirmation reminders...');

    try {
      // Find orders in work_completed status that are approaching auto-release
      const pendingConfirmations = await this.pg.query(`
        SELECT o.*, p.auto_release_at,
          EXTRACT(EPOCH FROM (p.auto_release_at - NOW())) / 3600 as hours_remaining,
          uc.email as customer_email
        FROM orders o
        JOIN payments p ON p.order_id = o.id
        JOIN users uc ON uc.id = o.customer_id
        WHERE o.status = 'work_completed'
          AND p.status = 'held'
          AND p.auto_release_at > NOW()
          AND p.auto_release_at < NOW() + INTERVAL '24 hours'
      `);

      for (const order of pendingConfirmations) {
        const hoursRemaining = Math.round(order.hours_remaining);

        // Check if we already sent a reminder in the last 12 hours
        const recentReminders = await this.pg.query(`
          SELECT id FROM notifications
          WHERE user_id = $1
            AND notification_type = 'confirm_reminder'
            AND data->>'orderId' = $2
            AND created_at > NOW() - INTERVAL '12 hours'
        `, [order.customer_id, order.id.toString()]);

        if (recentReminders.length === 0) {
          await this.pg.query(`
            INSERT INTO notifications (
              tenant_id, user_id, notification_type, title, body, data
            ) VALUES (
              $1, $2, 'confirm_reminder',
              'Confirmă lucrarea sau raportează o problemă',
              $3,
              $4
            )
          `, [
            order.tenant_id,
            order.customer_id,
            `Lucrarea pentru comanda #${order.id} a fost marcată ca finalizată. Ai ${hoursRemaining} ore să confirmi sau să raportezi o problemă. Dacă nu răspunzi, plata se va elibera automat.`,
            JSON.stringify({ orderId: order.id, hoursRemaining }),
          ]);

          this.logger.log(`📧 Sent reminder for order #${order.id} (${hoursRemaining}h remaining)`);
        }
      }
    } catch (error) {
      this.logger.error('❌ Error sending confirmation reminders:', error);
    }
  }

  /**
   * Auto-confirm orders where timeout expired
   * Runs every 10 minutes
   */
  @Cron('*/10 * * * *')
  async autoConfirmExpiredOrders() {
    this.logger.log('⏰ Checking for orders to auto-confirm...');

    try {
      // Find orders where auto_release_at has passed
      const expiredOrders = await this.pg.query(`
        SELECT o.id as order_id, p.id as payment_id
        FROM orders o
        JOIN payments p ON p.order_id = o.id
        WHERE o.status = 'work_completed'
          AND p.status = 'held'
          AND p.auto_release_at <= NOW()
      `);

      for (const order of expiredOrders) {
        try {
          // Release the payment
          await this.paymentsService.releaseEscrow({ 
            paymentId: order.payment_id,
            notes: 'Auto-released due to confirmation timeout'
          });

          // Send system message to chat
          await this.pg.query(`
            INSERT INTO chat_messages (
              tenant_id, order_id, sender_id, sender_role, message_type, content
            ) SELECT 
              tenant_id, id, 0, 'system', 'system',
              'Plata a fost eliberată automat deoarece clientul nu a răspuns în termenul de 48 ore.'
            FROM orders WHERE id = $1
          `, [order.order_id]);

          this.logger.log(`✅ Auto-released payment for order #${order.order_id}`);
        } catch (error) {
          this.logger.error(`❌ Error auto-releasing order #${order.order_id}:`, error);
        }
      }
    } catch (error) {
      this.logger.error('❌ Error in auto-confirm process:', error);
    }
  }

  /**
   * Cleanup old completed tasks
   * Runs daily at 3 AM
   */
  @Cron('0 3 * * *')
  async cleanupOldTasks() {
    this.logger.log('🧹 Cleaning up old scheduled tasks...');

    try {
      const result = await this.pg.query(`
        DELETE FROM scheduled_tasks
        WHERE status IN ('executed', 'cancelled')
          AND created_at < NOW() - INTERVAL '30 days'
        RETURNING id
      `);

      this.logger.log(`🗑️ Cleaned up ${result.length} old tasks`);
    } catch (error) {
      this.logger.error('❌ Error cleaning up tasks:', error);
    }
  }
}

