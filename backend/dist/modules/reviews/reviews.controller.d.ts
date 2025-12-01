import { ReviewsService } from './reviews.service';
import { CreateReviewDto, RespondToReviewDto, BlockUserDto } from './dto/review.dto';
export declare class ReviewsController {
    private readonly reviewsService;
    constructor(reviewsService: ReviewsService);
    create(body: CreateReviewDto): Promise<any>;
    respond(body: RespondToReviewDto): Promise<{
        success: boolean;
        message: string;
    }>;
    getForUser(userId: number, limit?: string, offset?: string): Promise<{
        reviews: any;
        stats: any;
    }>;
    getByOrderId(orderId: number): Promise<any>;
    findAll(minRating?: string, hasResponse?: string): Promise<any>;
    blockUser(body: BlockUserDto): Promise<any>;
    unblockUser(userId: number): Promise<{
        success: boolean;
    }>;
    isBlocked(userId: number): Promise<{
        isBlocked: boolean;
    }>;
    getBlockedUsers(): Promise<any>;
}
