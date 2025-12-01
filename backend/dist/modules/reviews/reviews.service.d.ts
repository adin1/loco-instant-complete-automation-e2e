import { PgService } from '../../infra/db/pg.service';
import { CreateReviewDto, RespondToReviewDto, BlockUserDto } from './dto/review.dto';
export declare class ReviewsService {
    private pg;
    constructor(pg: PgService);
    create(dto: CreateReviewDto, raterId: number, raterRole: 'customer' | 'provider'): Promise<any>;
    respond(dto: RespondToReviewDto, responderId: number): Promise<{
        success: boolean;
        message: string;
    }>;
    getForUser(userId: number, options?: {
        limit?: number;
        offset?: number;
        publicOnly?: boolean;
    }): Promise<{
        reviews: any;
        stats: any;
    }>;
    getByOrderId(orderId: number): Promise<any>;
    blockUser(dto: BlockUserDto, blockerId: number, blockerRole: 'customer' | 'provider'): Promise<any>;
    unblockUser(blockedId: number, blockerId: number): Promise<{
        success: boolean;
    }>;
    isBlocked(userId1: number, userId2: number): Promise<{
        isBlocked: boolean;
    }>;
    getBlockedUsers(blockerId: number): Promise<any>;
    findAll(filters?: {
        minRating?: number;
        hasResponse?: boolean;
    }): Promise<any>;
    private updateProviderRating;
}
