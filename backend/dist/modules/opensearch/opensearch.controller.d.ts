import { OpensearchService } from './opensearch.service';
import { CreateOpensearchDto } from './create-opensearch.dto';
export declare class OpensearchController {
    private readonly opensearchService;
    constructor(opensearchService: OpensearchService);
    create(index: string, id: string, body: CreateOpensearchDto): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
    read(index: string, id: string): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
    update(index: string, id: string, body: CreateOpensearchDto): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
    delete(index: string, id: string): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
    search(index: string, body: any): Promise<import("@opensearch-project/opensearch/.").ApiResponse<Record<string, any>, unknown>>;
}
