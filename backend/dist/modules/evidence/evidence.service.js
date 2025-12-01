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
exports.EvidenceService = void 0;
const common_1 = require("@nestjs/common");
const pg_service_1 = require("../../infra/db/pg.service");
const evidence_dto_1 = require("./dto/evidence.dto");
let EvidenceService = class EvidenceService {
    constructor(pg) {
        this.pg = pg;
    }
    async create(dto, uploadedBy) {
        const { orderId, evidenceType, mediaType, fileUrl, thumbnailUrl, fileSizeBytes, durationSeconds, description, locationLat, locationLng } = dto;
        const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
        if (orderRows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        const order = orderRows[0];
        const rows = await this.pg.query(`INSERT INTO order_evidence (
        tenant_id, order_id, uploaded_by, evidence_type, media_type,
        file_url, thumbnail_url, file_size_bytes, duration_seconds,
        description, location_lat, location_lng
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
      ) RETURNING *`, [
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
        ]);
        return rows[0];
    }
    async getByOrderId(orderId) {
        const rows = await this.pg.query(`SELECT e.*, u.email as uploader_email, u.role as uploader_role
       FROM order_evidence e
       JOIN users u ON u.id = e.uploaded_by
       WHERE e.order_id = $1
       ORDER BY e.created_at ASC`, [orderId]);
        return rows;
    }
    async getByType(orderId, evidenceType) {
        if (!evidence_dto_1.EVIDENCE_TYPES.includes(evidenceType)) {
            throw new common_1.BadRequestException('Invalid evidence type');
        }
        const rows = await this.pg.query(`SELECT * FROM order_evidence 
       WHERE order_id = $1 AND evidence_type = $2
       ORDER BY created_at ASC`, [orderId, evidenceType]);
        return rows;
    }
    async checkRequiredEvidence(orderId) {
        const evidence = await this.getByOrderId(orderId);
        const hasBefore = evidence.some((e) => e.evidence_type === 'before_work');
        const hasAfter = evidence.some((e) => e.evidence_type === 'after_work');
        const hasTestProof = evidence.some((e) => e.evidence_type === 'test_proof');
        return {
            hasBefore,
            hasAfter,
            hasTestProof,
            isComplete: hasBefore && hasAfter,
            evidence,
        };
    }
    async getUploadUrl(dto) {
        const { orderId, evidenceType, mediaType, fileName, fileSize } = dto;
        const orderRows = await this.pg.query('SELECT * FROM orders WHERE id = $1', [orderId]);
        if (orderRows.length === 0) {
            throw new common_1.NotFoundException('Order not found');
        }
        const maxSize = mediaType === 'video' ? 200 * 1024 * 1024 : 50 * 1024 * 1024;
        if (fileSize > maxSize) {
            throw new common_1.BadRequestException(`File too large. Max size: ${maxSize / 1024 / 1024}MB`);
        }
        const timestamp = Date.now();
        const ext = fileName.split('.').pop();
        const uniqueFileName = `orders/${orderId}/${evidenceType}/${timestamp}_${Math.random().toString(36).substring(7)}.${ext}`;
        const mockUploadUrl = `https://storage.loco-instant.local/upload/${uniqueFileName}`;
        const mockFileUrl = `https://cdn.loco-instant.local/${uniqueFileName}`;
        return {
            uploadUrl: mockUploadUrl,
            fileUrl: mockFileUrl,
            fileName: uniqueFileName,
            expiresIn: 3600,
        };
    }
    async delete(evidenceId) {
        const rows = await this.pg.query('DELETE FROM order_evidence WHERE id = $1 RETURNING *', [evidenceId]);
        if (rows.length === 0) {
            throw new common_1.NotFoundException('Evidence not found');
        }
        return { success: true, deleted: rows[0] };
    }
    async getForDispute(orderId) {
        var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m;
        const rows = await this.pg.query(`SELECT 
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
       ORDER BY type_order, e.created_at ASC`, [orderId]);
        const grouped = {};
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
                beforeWork: (_b = (_a = grouped['before_work']) === null || _a === void 0 ? void 0 : _a.length) !== null && _b !== void 0 ? _b : 0,
                duringWork: (_d = (_c = grouped['during_work']) === null || _c === void 0 ? void 0 : _c.length) !== null && _d !== void 0 ? _d : 0,
                afterWork: (_f = (_e = grouped['after_work']) === null || _e === void 0 ? void 0 : _e.length) !== null && _f !== void 0 ? _f : 0,
                testProof: (_h = (_g = grouped['test_proof']) === null || _g === void 0 ? void 0 : _g.length) !== null && _h !== void 0 ? _h : 0,
                problemReport: (_k = (_j = grouped['problem_report']) === null || _j === void 0 ? void 0 : _j.length) !== null && _k !== void 0 ? _k : 0,
                disputeEvidence: (_m = (_l = grouped['dispute_evidence']) === null || _l === void 0 ? void 0 : _l.length) !== null && _m !== void 0 ? _m : 0,
            },
        };
    }
};
exports.EvidenceService = EvidenceService;
exports.EvidenceService = EvidenceService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [pg_service_1.PgService])
], EvidenceService);
//# sourceMappingURL=evidence.service.js.map