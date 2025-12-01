import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PgService } from '../../infra/db/pg.service';
import { CreateEvidenceDto, UploadRequestDto, EVIDENCE_TYPES } from './dto/evidence.dto';

@Injectable()
export class EvidenceService {
  constructor(private pg: PgService) {}

  /**
   * Create evidence record
   */
  async create(dto: CreateEvidenceDto, uploadedBy: number) {
    const { orderId, evidenceType, mediaType, fileUrl, thumbnailUrl, fileSizeBytes, durationSeconds, description, locationLat, locationLng } = dto;

    // Verify order exists
    const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
    if (orderRows.length === 0) {
      throw new NotFoundException('Order not found');
    }
    const order = orderRows[0];

    // Insert evidence
    const rows = await this.pg.query(
      `INSERT INTO order_evidence (
        tenant_id, order_id, uploaded_by, evidence_type, media_type,
        file_url, thumbnail_url, file_size_bytes, duration_seconds,
        description, location_lat, location_lng
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
      ) RETURNING *`,
      [
        order.tenant_id,
        orderId,
        uploadedBy,
        evidenceType,
        mediaType,
        fileUrl,
        thumbnailUrl,
        fileSizeBytes,
        durationSeconds,
        description,
        locationLat,
        locationLng,
      ]
    );

    return rows[0];
  }

  /**
   * Get evidence for an order
   */
  async getByOrderId(orderId: number) {
    const rows = await this.pg.query(
      `SELECT e.*, u.email as uploader_email, u.role as uploader_role
       FROM order_evidence e
       JOIN users u ON u.id = e.uploaded_by
       WHERE e.order_id = $1
       ORDER BY e.created_at ASC`,
      [orderId]
    );
    return rows;
  }

  /**
   * Get evidence by type
   */
  async getByType(orderId: number, evidenceType: string) {
    if (!EVIDENCE_TYPES.includes(evidenceType as any)) {
      throw new BadRequestException('Invalid evidence type');
    }

    const rows = await this.pg.query(
      `SELECT * FROM order_evidence 
       WHERE order_id = $1 AND evidence_type = $2
       ORDER BY created_at ASC`,
      [orderId, evidenceType]
    );
    return rows;
  }

  /**
   * Check if required evidence exists
   */
  async checkRequiredEvidence(orderId: number) {
    const evidence = await this.getByOrderId(orderId);

    const hasBefore = evidence.some((e: any) => e.evidence_type === 'before_work');
    const hasAfter = evidence.some((e: any) => e.evidence_type === 'after_work');
    const hasTestProof = evidence.some((e: any) => e.evidence_type === 'test_proof');

    return {
      hasBefore,
      hasAfter,
      hasTestProof,
      isComplete: hasBefore && hasAfter,
      evidence,
    };
  }

  /**
   * Get upload URL (for presigned S3/Cloud Storage upload)
   */
  async getUploadUrl(dto: UploadRequestDto) {
    const { orderId, evidenceType, mediaType, fileName, fileSize } = dto;

    // Verify order exists
    const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
    if (orderRows.length === 0) {
      throw new NotFoundException('Order not found');
    }

    // Validate file size (max 50MB for images, 200MB for videos)
    const maxSize = mediaType === 'video' ? 200 * 1024 * 1024 : 50 * 1024 * 1024;
    if (fileSize > maxSize) {
      throw new BadRequestException(`File too large. Max size: ${maxSize / 1024 / 1024}MB`);
    }

    // Generate unique filename
    const timestamp = Date.now();
    const ext = fileName.split('.').pop();
    const uniqueFileName = `orders/${orderId}/${evidenceType}/${timestamp}_${Math.random().toString(36).substring(7)}.${ext}`;

    // TODO: Replace with real presigned URL generation
    // For S3:
    // const s3 = new S3Client({ region: process.env.AWS_REGION });
    // const command = new PutObjectCommand({
    //   Bucket: process.env.S3_BUCKET,
    //   Key: uniqueFileName,
    //   ContentType: mediaType === 'video' ? 'video/mp4' : 'image/jpeg',
    // });
    // const uploadUrl = await getSignedUrl(s3, command, { expiresIn: 3600 });

    // Mock response for development
    const mockUploadUrl = `https://storage.loco-instant.local/upload/${uniqueFileName}`;
    const mockFileUrl = `https://cdn.loco-instant.local/${uniqueFileName}`;

    return {
      uploadUrl: mockUploadUrl,
      fileUrl: mockFileUrl,
      fileName: uniqueFileName,
      expiresIn: 3600, // 1 hour
    };
  }

  /**
   * Delete evidence (admin only)
   */
  async delete(evidenceId: number) {
    const rows = await this.pg.query(
      'DELETE FROM order_evidence WHERE id = $1 RETURNING *',
      [evidenceId]
    );
    
    if (rows.length === 0) {
      throw new NotFoundException('Evidence not found');
    }

    return { success: true, deleted: rows[0] };
  }

  /**
   * Get all evidence for dispute
   */
  async getForDispute(orderId: number) {
    const rows = await this.pg.query(
      `SELECT 
        e.*,
        u.email as uploader_email,
        u.role as uploader_role,
        CASE 
          WHEN e.evidence_type = 'before_work' THEN 1
          WHEN e.evidence_type = 'during_work' THEN 2
          WHEN e.evidence_type = 'after_work' THEN 3
          WHEN e.evidence_type = 'test_proof' THEN 4
          WHEN e.evidence_type = 'problem_report' THEN 5
          WHEN e.evidence_type = 'dispute_evidence' THEN 6
        END as type_order
       FROM order_evidence e
       JOIN users u ON u.id = e.uploaded_by
       WHERE e.order_id = $1
       ORDER BY type_order, e.created_at ASC`,
      [orderId]
    );
    
    // Group by type
    const grouped: Record<string, any[]> = {};
    for (const row of rows) {
      if (!grouped[row.evidence_type]) {
        grouped[row.evidence_type] = [];
      }
      grouped[row.evidence_type].push(row);
    }

    return {
      all: rows,
      grouped,
      summary: {
        beforeWork: grouped['before_work']?.length ?? 0,
        duringWork: grouped['during_work']?.length ?? 0,
        afterWork: grouped['after_work']?.length ?? 0,
        testProof: grouped['test_proof']?.length ?? 0,
        problemReport: grouped['problem_report']?.length ?? 0,
        disputeEvidence: grouped['dispute_evidence']?.length ?? 0,
      },
    };
  }
}

