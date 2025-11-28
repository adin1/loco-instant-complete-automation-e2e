import { Client } from '@opensearch-project/opensearch';
import { Injectable } from '@nestjs/common';

@Injectable()
export class OpenSearchService {
  private client: Client | null = null;

  constructor() {
    // ✅ Protecție pentru cazurile fără OpenSearch activ
    if (!process.env.OS_NODE) {
      console.warn('⚠️ OpenSearch not configured, continuing without it');
      return;
    }

    // (alternativ, dacă folosești flag-ul DISABLE_OPENSEARCH)
    if (process.env.DISABLE_OPENSEARCH === 'true') {
      console.warn('⚠️ OpenSearch disabled by env flag');
      return;
    }

    // 🔧 Inițializează clientul doar dacă există config
    this.client = new Client({
      node: process.env.OS_NODE,
      auth: {
        username: process.env.OS_USERNAME || 'admin',
        password: process.env.OS_PASSWORD || 'admin',
      },
    });

    console.log('✅ OpenSearch client initialized');
  }

  getClient(): Client | null {
    return this.client;
  }
}
