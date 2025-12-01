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
exports.ChatService = void 0;
const common_1 = require("@nestjs/common");
const pg_service_1 = require("../../infra/db/pg.service");
let ChatService = class ChatService {
    constructor(pg) {
        this.pg = pg;
    }
    async sendMessage(dto, senderId, senderRole) {
        const { orderId, content, messageType = 'text', mediaUrl, metadata } = dto;
        const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
        if (orderRows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        const order = orderRows[0];
        const rows = await this.pg.query(`INSERT INTO chat_messages (
        tenant_id, order_id, sender_id, sender_role, message_type, content, media_url, metadata
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8
      ) RETURNING *`, [order.tenant_id, orderId, senderId, senderRole, messageType, content, mediaUrl, metadata ? JSON.stringify(metadata) : null]);
        const message = rows[0];
        const recipientId = senderRole === 'customer'
            ? await this.getProviderUserId(order.provider_id)
            : order.customer_id;
        if (recipientId && senderRole !== 'system') {
            await this.pg.query(`INSERT INTO notifications (
          tenant_id, user_id, notification_type, title, body, data
        ) VALUES (
          $1, $2, 'new_message', $3, $4, $5
        )`, [
                order.tenant_id,
                recipientId,
                'Mesaj nou',
                content.length > 50 ? content.substring(0, 50) + '...' : content,
                JSON.stringify({ orderId, messageId: message.id }),
            ]);
        }
        return {
            success: true,
            message: {
                id: message.id,
                sentAt: message.created_at,
                ...dto,
                senderId,
                senderRole,
            },
        };
    }
    async getMessages(orderId, limit = 50, before) {
        let query = `
      SELECT cm.*, u.email as sender_email
      FROM chat_messages cm
      JOIN users u ON u.id = cm.sender_id
      WHERE cm.order_id = $1
    `;
        const params = [orderId];
        if (before) {
            query += ` AND cm.created_at < $${params.length + 1}`;
            params.push(before);
        }
        query += ` ORDER BY cm.created_at DESC LIMIT $${params.length + 1}`;
        params.push(limit);
        const rows = await this.pg.query(query, params);
        return rows.reverse();
    }
    async markRead(dto, readerId) {
        const { orderId, beforeTimestamp } = dto;
        const timestamp = beforeTimestamp !== null && beforeTimestamp !== void 0 ? beforeTimestamp : new Date().toISOString();
        await this.pg.query(`UPDATE chat_messages 
       SET is_read = TRUE, read_at = NOW()
       WHERE order_id = $1 
         AND sender_id != $2 
         AND is_read = FALSE
         AND created_at <= $3`, [orderId, readerId, timestamp]);
        return { success: true };
    }
    async getUnreadCount(orderId, userId) {
        const rows = await this.pg.query(`SELECT COUNT(*) as count
       FROM chat_messages
       WHERE order_id = $1 AND sender_id != $2 AND is_read = FALSE`, [orderId, userId]);
        return { unreadCount: parseInt(rows[0].count, 10) };
    }
    async getUserChats(userId, role) {
        const roleCondition = role === 'customer' ? 'o.customer_id = $1' : 'p.user_id = $1';
        const rows = await this.pg.query(`
      SELECT DISTINCT ON (o.id)
        o.id as order_id,
        o.status as order_status,
        o.created_at as order_date,
        cm.content as last_message,
        cm.created_at as last_message_at,
        cm.sender_role as last_message_sender,
        CASE WHEN ${role === 'customer' ? 'pr.display_name' : 'uc.email'} IS NULL 
             THEN 'Unknown' 
             ELSE ${role === 'customer' ? 'pr.display_name' : 'uc.email'} END as other_party_name,
        (SELECT COUNT(*) FROM chat_messages WHERE order_id = o.id AND sender_id != $1 AND is_read = FALSE) as unread_count
      FROM orders o
      LEFT JOIN providers p ON p.id = o.provider_id
      LEFT JOIN providers pr ON pr.id = o.provider_id
      LEFT JOIN users uc ON uc.id = o.customer_id
      LEFT JOIN chat_messages cm ON cm.order_id = o.id
      WHERE ${roleCondition}
      ORDER BY o.id, cm.created_at DESC
    `, [userId]);
        return rows;
    }
    async sendSystemMessage(orderId, content, messageType = 'system', metadata) {
        const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
        if (orderRows.length === 0)
            return null;
        const order = orderRows[0];
        const systemUserId = 0;
        const rows = await this.pg.query(`INSERT INTO chat_messages (
        tenant_id, order_id, sender_id, sender_role, message_type, content, metadata
      ) VALUES (
        $1, $2, $3, 'system', $4, $5, $6
      ) RETURNING *`, [order.tenant_id, orderId, systemUserId, messageType, content, metadata ? JSON.stringify(metadata) : null]);
        return rows[0];
    }
    async getProviderUserId(providerId) {
        var _a, _b;
        if (!providerId)
            return null;
        const rows = await this.pg.query('SELECT user_id FROM providers WHERE id = $1', [providerId]);
        return (_b = (_a = rows[0]) === null || _a === void 0 ? void 0 : _a.user_id) !== null && _b !== void 0 ? _b : null;
    }
};
exports.ChatService = ChatService;
exports.ChatService = ChatService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService])
], ChatService);
//# sourceMappingURL=chat.service.js.map