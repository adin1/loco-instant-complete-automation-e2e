import { Injectable } from '@nestjs/common';

@Injectable()
export class UsersService {
  // TODO: Replace with real persistence (PostgreSQL) later.
  private readonly users: any[] = [];

  async findAll() {
    return this.users;
  }

  async create(body: any) {
    const user = { id: this.users.length + 1, ...body };
    this.users.push(user);
    return user;
  }
}


