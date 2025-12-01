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
var ScheduledTasksWorker_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.ScheduledTasksWorker = void 0;
const common_1 = require("@nestjs/common");
const schedule_1 = require("@nestjs/schedule");
const pg_service_1 = require("../infra/db/pg.service");
const payments_service_1 = require("../modules/payments/payments.service");
let ScheduledTasksWorker = ScheduledTasksWorker_1 = class ScheduledTasksWorker {
    constructor(pg, paymentsService) {
        this.pg = pg;
        this.paymentsService = paymentsService;
        this.logger = new common_1.Logger(ScheduledTasksWorker_1.name);
    }
    async processAutoReleasePayments() {
        this.logger.log('🔄 Processing auto-release payments...');
        try {
            const result = await this.paymentsService.processAutoRelease();
            if (result.processed > 0) {
                this.logger.log(`✅ Processed ${result.processed} auto-release payments`);
            }
        }
        catch (error) {
            this.logger.error('❌ Error processing auto-release payments:', error);
        }
    }
    async sendConfirmationReminders() {
        this.logger.log('🔔 Sending confirmation reminders...');
        try {
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
        }
        catch (error) {
            this.logger.error('❌ Error sending confirmation reminders:', error);
        }
    }
    async autoConfirmExpiredOrders() {
        this.logger.log('⏰ Checking for orders to auto-confirm...');
        try {
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
                    await this.paymentsService.releaseEscrow({
                        paymentId: order.payment_id,
                        notes: 'Auto-released due to confirmation timeout'
                    });
                    await this.pg.query(`
            INSERT INTO chat_messages (
              tenant_id, order_id, sender_id, sender_role, message_type, content
            ) SELECT 
              tenant_id, id, 0, 'system', 'system',
              'Plata a fost eliberată automat deoarece clientul nu a răspuns în termenul de 48 ore.'
            FROM orders WHERE id = $1
          `, [order.order_id]);
                    this.logger.log(`✅ Auto-released payment for order #${order.order_id}`);
                }
                catch (error) {
                    this.logger.error(`❌ Error auto-releasing order #${order.order_id}:`, error);
                }
            }
        }
        catch (error) {
            this.logger.error('❌ Error in auto-confirm process:', error);
        }
    }
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
        }
        catch (error) {
            this.logger.error('❌ Error cleaning up tasks:', error);
        }
    }
};
exports.ScheduledTasksWorker = ScheduledTasksWorker;
__decorate([
    (0, schedule_1.Cron)(schedule_1.CronExpression.EVERY_5_MINUTES),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ScheduledTasksWorker.prototype, "processAutoReleasePayments", null);
__decorate([
    (0, schedule_1.Cron)(schedule_1.CronExpression.EVERY_HOUR),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ScheduledTasksWorker.prototype, "sendConfirmationReminders", null);
__decorate([
    (0, schedule_1.Cron)('*/10 * * * *'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ScheduledTasksWorker.prototype, "autoConfirmExpiredOrders", null);
__decorate([
    (0, schedule_1.Cron)('0 3 * * *'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ScheduledTasksWorker.prototype, "cleanupOldTasks", null);
exports.ScheduledTasksWorker = ScheduledTasksWorker = ScheduledTasksWorker_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService,
        payments_service_1.PaymentsService])
], ScheduledTasksWorker);
//# sourceMappingURL=scheduled-tasks.worker.js.map