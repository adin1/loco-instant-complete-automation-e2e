import { Injectable, NotFoundException } from '@nestjs/common';
import { PgService } from '../../infra/db/pg.service';

export interface SendMessageDto {
  orderId: number;
  content: string;
  messageType?: 'text' | 'image' | 'video' | 'audio' | 'file' | 'location' | 'system' | 'price_quote' | 'status_update';
  mediaUrl?: string;
  metadata?: any;
}

export interface MarkReadDto {
  orderId: number;
  beforeTimestamp?: string;
}

@Injectable()
export class ChatService {
  constructor(private pg: PgService) {}

  /**
   * Send a message
   */
  async sendMessage(dto: SendMessageDto, senderId: number, senderRole: 'customer' | 'provider' | 'system') {
    const { orderId, content, messageType = 'text', mediaUrl, metadata } = dto;

    // Verify order exists
    const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
    if (orderRows.length === 0) {
      throw new NotFoundException('Order not found');
    }
    const order = orderRows[0];

    // Insert message
    const rows = await this.pg.query(
      `INSERT INTO chat_messages (
        tenant_id, order_id, sender_id, sender_role, message_type, content, media_url, metadata
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8
      ) RETURNING *`,
      [order.tenant_id, orderId, senderId, senderRole, messageType, content, mediaUrl, metadata ? JSON.stringify(metadata) : null]
    );

    const message = rows[0];

    // TODO: Emit via WebSocket to other party
    // this.socketGateway.emitToRoom(`order_${orderId}`, 'new_message', message);

    // Create notification for recipient
    const recipientId = senderRole === 'customer' 
      ? await this.getProviderUserId(order.provider_id)
      : order.customer_id;

    if (recipientId && senderRole !== 'system') {
      await this.pg.query(
        `INSERT INTO notifications (
          tenant_id, user_id, notification_type, title, body, data
        ) VALUES (
          $1, $2, 'new_message', $3, $4, $5
        )`,
        [
          order.tenant_id,
          recipientId,
          'Mesaj nou',
          content.length > 50 ? content.substring(0, 50) + '...' : content,
          JSON.stringify({ orderId, messageId: message.id }),
        ]
      );
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

  /**
   * Get messages for an order
   */
  async getMessages(orderId: number, limit = 50, before?: string) {
    let query = `
      SELECT cm.*, u.email as sender_email
      FROM chat_messages cm
      JOIN users u ON u.id = cm.sender_id
      WHERE cm.order_id = $1
    `;
    const params: any[] = [orderId];

    if (before) {
      query += ` AND cm.created_at < $${params.length + 1}`;
      params.push(before);
    }

    query += ` ORDER BY cm.created_at DESC LIMIT $${params.length + 1}`;
    params.push(limit);

    const rows = await this.pg.query(query, params);

    // Return in chronological order
    return rows.reverse();
  }

  /**
   * Mark messages as read
   */
  async markRead(dto: MarkReadDto, readerId: number) {
    const { orderId, beforeTimestamp } = dto;

    const timestamp = beforeTimestamp ?? new Date().toISOString();

    await this.pg.query(
      `UPDATE chat_messages 
       SET is_read = TRUE, read_at = NOW()
       WHERE order_id = $1 
         AND sender_id != $2 
         AND is_read = FALSE
         AND created_at <= $3`,
      [orderId, readerId, timestamp]
    );

    return { success: true };
  }

  /**
   * Get unread count for an order
   */
  async getUnreadCount(orderId: number, userId: number) {
    const rows = await this.pg.query(
      `SELECT COUNT(*) as count
       FROM chat_messages
       WHERE order_id = $1 AND sender_id != $2 AND is_read = FALSE`,
      [orderId, userId]
    );
    return { unreadCount: parseInt(rows[0].count, 10) };
  }

  /**
   * Get all chats for a user (order list with last message)
   */
  async getUserChats(userId: number, role: 'customer' | 'provider') {
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

  /**
   * Send system message (automated)
   */
  async sendSystemMessage(orderId: number, content: string, messageType: 'system' | 'status_update' = 'system', metadata?: any) {
    const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
    if (orderRows.length === 0) return null;

    const order = orderRows[0];

    // Use a system user ID (0 or create one)
    const systemUserId = 0;

    const rows = await this.pg.query(
      `INSERT INTO chat_messages (
        tenant_id, order_id, sender_id, sender_role, message_type, content, metadata
      ) VALUES (
        $1, $2, $3, 'system', $4, $5, $6
      ) RETURNING *`,
      [order.tenant_id, orderId, systemUserId, messageType, content, metadata ? JSON.stringify(metadata) : null]
    );

    return rows[0];
  }

  /**
   * Helper: Get provider's user ID
   */
  private async getProviderUserId(providerId: number): Promise<number | null> {
    if (!providerId) return null;
    const rows = await this.pg.query('SELECT user_id FROM providers WHERE id = $1', [providerId]);
    return rows[0]?.user_id ?? null;
  }
}
