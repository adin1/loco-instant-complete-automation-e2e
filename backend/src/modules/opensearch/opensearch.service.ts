import { Injectable } from '@nestjs/common';
import { InjectOpensearchClient, OpensearchClient } from 'nestjs-opensearch';

@Injectable()
export class OpensearchService {
  constructor(
    @InjectOpensearchClient() private readonly searchClient: OpensearchClient,
  ) {}

  async createDocument(index: string, id: string, document: any) {
    return await this.searchClient.index({
      index,
      id,
      body: document,
    });
  }

  async getDocument(index: string, id: string) {
    return await this.searchClient.get({
      index,
      id,
    });
  }

  async updateDocument(index: string, id: string, document: any) {
    return await this.searchClient.update({
      index,
      id,
      body: {
        doc: document,
      },
    });
  }

  async deleteDocument(index: string, id: string) {
    return await this.searchClient.delete({
      index,
      id,
    });
  }

  async searchDocuments(index: string, body: any) {
    return await this.searchClient.search({
      index,
      body,
    });
  }
}
