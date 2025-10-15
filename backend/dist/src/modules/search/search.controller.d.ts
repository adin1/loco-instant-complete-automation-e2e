import { SearchService } from './search.service';
export declare class SearchController {
    private readonly svc;
    constructor(svc: SearchService);
    providers(q: string, lat: string, lon: string, radius?: string): Promise<any>;
}
