import { OpensearchClient } from 'nestjs-opensearch';
export declare class OpensearchService {
    private readonly searchClient;
    constructor(searchClient: OpensearchClient);
    createDocument(index: string, id: string, document: any): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
    getDocument(index: string, id: string): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
    updateDocument(index: string, id: string, document: any): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
    deleteDocument(index: string, id: string): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
    searchDocuments(index: string, body: any): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
}
