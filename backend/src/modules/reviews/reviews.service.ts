import { Injectable } from '@nestjs/common';

@Injectable()
export class ReviewsService {
  private readonly reviews: any[] = [];

  async findAll() {
    return this.reviews;
  }

  async create(body: any) {
    const review = {
      id: this.reviews.length + 1,
      createdAt: new Date().toISOString(),
      ...body,
    };
    this.reviews.push(review);
    return review;
  }
}


