import { RequestsService } from '../requests/requests.service';
export declare class OffersService {
    private readonly requestsService;
    constructor(requestsService: RequestsService);
    private readonly offers;
    findAll(): Promise<any[]>;
    create(body: any): Promise<any>;
    acceptOffer(requestId: string, offerId: string): Promise<{
        success: boolean;
        message: string;
        request?: undefined;
        offer?: undefined;
    } | {
        success: boolean;
        request: any;
        offer: any;
        message?: undefined;
    }>;
}
