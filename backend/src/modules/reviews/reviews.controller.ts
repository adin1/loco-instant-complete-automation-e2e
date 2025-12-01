import { Controller, Post, Get, Delete, Body, Param, Query, ParseIntPipe, UsePipes, ValidationPipe } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto, RespondToReviewDto, BlockUserDto } from './dto/review.dto';

@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  /**
   * Create a review
   */
  @Post()
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async create(@Body() body: CreateReviewDto) {
    // TODO: Get rater info from auth token
    const raterId = 1; // Mock user ID
    const raterRole = 'customer' as const;
    return this.reviewsService.create(body, raterId, raterRole);
  }

  /**
   * Respond to a review
   */
  @Post('respond')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async respond(@Body() body: RespondToReviewDto) {
    // TODO: Get responder ID from auth token
    const responderId = 1;
    return this.reviewsService.respond(body, responderId);
  }

  /**
   * Get reviews for a user
   */
  @Get('user/:userId')
  async getForUser(
    @Param('userId', ParseIntPipe) userId: number,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.reviewsService.getForUser(userId, {
      limit: limit ? parseInt(limit, 10) : undefined,
      offset: offset ? parseInt(offset, 10) : undefined,
    });
  }

  /**
   * Get reviews for an order
   */
  @Get('order/:orderId')
  async getByOrderId(@Param('orderId', ParseIntPipe) orderId: number) {
    return this.reviewsService.getByOrderId(orderId);
  }

  /**
   * Get all reviews (admin)
   */
  @Get()
  async findAll(
    @Query('minRating') minRating?: string,
    @Query('hasResponse') hasResponse?: string,
  ) {
    return this.reviewsService.findAll({
      minRating: minRating ? parseInt(minRating, 10) : undefined,
      hasResponse: hasResponse === 'true' ? true : hasResponse === 'false' ? false : undefined,
    });
  }

  /**
   * Block a user
   */
  @Post('block')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async blockUser(@Body() body: BlockUserDto) {
    // TODO: Get blocker info from auth token
    const blockerId = 1;
    const blockerRole = 'customer' as const;
    return this.reviewsService.blockUser(body, blockerId, blockerRole);
  }

  /**
   * Unblock a user
   */
  @Delete('block/:userId')
  async unblockUser(@Param('userId', ParseIntPipe) userId: number) {
    // TODO: Get blocker ID from auth token
    const blockerId = 1;
    return this.reviewsService.unblockUser(userId, blockerId);
  }

  /**
   * Check if blocked
   */
  @Get('block/check/:userId')
  async isBlocked(@Param('userId', ParseIntPipe) userId: number) {
    // TODO: Get current user ID from auth token
    const currentUserId = 1;
    return this.reviewsService.isBlocked(currentUserId, userId);
  }

  /**
   * Get blocked users list
   */
  @Get('blocked')
  async getBlockedUsers() {
    // TODO: Get current user ID from auth token
    const blockerId = 1;
    return this.reviewsService.getBlockedUsers(blockerId);
  }
}
