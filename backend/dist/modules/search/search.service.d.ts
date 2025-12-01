import { OpenSearchService } from '../../infra/os/opensearch.service';
export declare class SearchService {
    private os;
    constructor(os: OpenSearchService);
    searchProviders(q: string, lat: number, lon: number, radius?: string): Promise<any>;
}
