import { Injectable } from '@nestjs/common';
import { Pool } from 'pg';

@Injectable()
export class PgService {
  private pool = new Pool({
    host: process.env.PG_HOST,
    port: Number(process.env.PG_PORT || 5432),
    database: process.env.PG_DATABASE,
    user: process.env.PG_USER,
    password: process.env.PG_PASSWORD,
    ssl: process.env.PG_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
  });

  async query<T = any>(text: string, params?: any[]) {
    const client = await this.pool.connect();
    try {
      const res = await client.query<T>(text, params);
      // @ts-ignore
      return res.rows;
    } finally {
      client.release();
    }
  }
}