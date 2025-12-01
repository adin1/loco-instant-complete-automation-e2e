import { Client } from '@opensearch-project/opensearch';
export declare class OpenSearchService {
    private client;
    constructor();
    getClient(): Client | null;
}
