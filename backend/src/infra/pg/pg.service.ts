import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { Client } from 'pg';

@Injectable()
export class PgService implements OnModuleInit, OnModuleDestroy {
  private client: Client;

  constructor() {
    const isProd = process.env.NODE_ENV === 'production';

    // In dev, ignorăm variabilele PG_* globale și folosim config-ul din docker-compose.local.yml
    const dbName =
      (isProd ? process.env.PG_DATABASE || process.env.PG_DB : 'loco') || 'loco';

    const dbHost = isProd ? process.env.PG_HOST || 'localhost' : 'localhost';
    const dbPort = Number(process.env.PG_PORT) || 5432;
    const dbUser = isProd ? process.env.PG_USER || 'postgres' : 'postgres';
    const dbPassword = isProd ? process.env.PG_PASSWORD || 'postgres' : 'postgres';

    console.log('📦 PostgreSQL config:', {
      host: dbHost,
      port: dbPort,
      user: dbUser,
      database: dbName,
      env: process.env.NODE_ENV ?? 'development',
    });

    this.client = new Client({
      host: dbHost,
      port: dbPort,
      user: dbUser,
      password: dbPassword,
      database: dbName,
    });
  }

  async onModuleInit() {
    try {
      await this.client.connect();
      console.log('✅ Connected to PostgreSQL');
    } catch (err) {
      console.error('❌ Failed to connect to PostgreSQL:', err);
    }
  }

  async onModuleDestroy() {
    await this.client.end();
  }

  async query(sql: string, params?: any[]) {
    return this.client.query(sql, params);
  }
}
