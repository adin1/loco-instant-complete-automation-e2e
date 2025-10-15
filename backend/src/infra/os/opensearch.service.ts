import { Client } from '@opensearch-project/opensearch';
import { Injectable } from '@nestjs/common';

@Injectable()
export class OpenSearchService {
  public client: Client;
  constructor() {
    this.client = new Client({
      node: process.env.OS_NODE!,
      auth: { username: process.env.OS_USERNAME!, password: process.env.OS_PASSWORD! },
      ssl: { rejectUnauthorized: process.env.OS_TLS_REJECT_UNAUTHORIZED !== 'false' }
    });
  }
}