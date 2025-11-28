import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { Client } from 'pg';

@Injectable()
export class PgService implements OnModuleInit, OnModuleDestroy {
  private client: Client;

  constructor() {
    this.client = new Client({
      host: process.env.PG_HOST || 'localhost',
      port: Number(process.env.PG_PORT) || 5432,
      user: process.env.PG_USER || 'postgres',
      password: process.env.PG_PASSWORD || 'postgres',
      database: process.env.PG_DATABASE || 'loco',
    });
  }

  async onModuleInit() {
    try {
      await this.client.connect();
      console.log('✅ Connected to PostgreSQL');
    } catch (err) {
      // Don't crash the app if Postgres is not available locally.
      // We just log a concise warning and continue in degraded mode.
      const message =
        err instanceof Error ? err.message : 'Unknown PostgreSQL connection error';
      console.warn(
        `❌ Failed to connect to PostgreSQL (running without DB). Details: ${message}`,
      );
    }
  }

  async onModuleDestroy() {
    await this.client.end();
  }

  async query(sql: string, params?: any[]) {
    const res = await this.client.query(sql, params);
    return res.rows;
  }
}
