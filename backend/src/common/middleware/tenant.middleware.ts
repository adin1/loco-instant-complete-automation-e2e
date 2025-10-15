import { Injectable, NestMiddleware } from '@nestjs/common';
import { Pool } from 'pg';

@Injectable()
export class TenantMiddleware implements NestMiddleware {
  private pool = new Pool({
    host: process.env.PG_HOST,
    port: Number(process.env.PG_PORT || 5432),
    database: process.env.PG_DATABASE,
    user: process.env.PG_USER,
    password: process.env.PG_PASSWORD,
    ssl: process.env.PG_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
  });

  async use(req: any, res: any, next: () => void) {
    const tenantCode = process.env.TENANT_CODE || 'cluj';
    req.db = await this.pool.connect();
    await req.db.query(`select set_config('app.tenant_id', (select id::text from tenants where code=$1), true)`, [tenantCode]);
    res.on('finish', () => req.db.release());
    next();
  }
}