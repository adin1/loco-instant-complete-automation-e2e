import { OffersService } from './offers.service';
export declare class OffersController {
    private readonly offersService;
    constructor(offersService: OffersService);
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
