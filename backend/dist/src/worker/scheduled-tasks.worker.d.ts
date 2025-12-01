import { PgService } from '../infra/db/pg.service';
import { PaymentsService } from '../modules/payments/payments.service';
export declare class ScheduledTasksWorker {
    private pg;
    private paymentsService;
    private readonly logger;
    constructor(pg: PgService, paymentsService: PaymentsService);
    processAutoReleasePayments(): Promise<void>;
    sendConfirmationReminders(): Promise<void>;
    autoConfirmExpiredOrders(): Promise<void>;
    cleanupOldTasks(): Promise<void>;
}
