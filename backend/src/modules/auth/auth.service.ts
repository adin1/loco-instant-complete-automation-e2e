import { Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthService {
  private prisma = new PrismaClient();

  // Creează un nou utilizator (cu parola criptată)
  async register(email: string, password: string, name?: string) {
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new Error('User already exists');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await this.prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name,
      },
    });

    return newUser;
  }

  // Validează email + parolă
  async validateUser(email: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new Error('User not found');
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new Error('Invalid password');
    }

    return user;
  }

  // Login + generare token JWT
  async login(email: string, password: string) {
    // Demo mode - acceptă orice email cu parola "demo123" în development
    if (process.env.NODE_ENV !== 'production' && password === 'demo123') {
      // Caută sau creează utilizatorul demo
      let user = await this.prisma.user.findUnique({ where: { email } });
      
      if (!user) {
        // Returnează un user demo fără a-l crea în DB
        const demoUser = {
          id: -999,
          email,
          password: '',
          name: email.split('@')[0],
          role: 'customer',
        } as any;

        const payload = { sub: demoUser.id, email: demoUser.email };
        const token = jwt.sign(
          payload,
          process.env.JWT_SECRET || 'local_secret_key',
          { expiresIn: '7d' },
        );

        return {
          access_token: token,
          user: demoUser,
        };
      }

      const payload = { sub: user.id, email: user.email };
      const token = jwt.sign(
        payload,
        process.env.JWT_SECRET || 'local_secret_key',
        { expiresIn: '7d' },
      );

      return {
        access_token: token,
        user,
      };
    }

    // Demo fallback user – permite acces fără bază de date funcțională
    if (
      email === 'demo@loco-instant.ro' &&
      password === 'Parola123!' &&
      (process.env.ALLOW_DEMO_LOGIN === '1' || process.env.NODE_ENV !== 'production')
    ) {
      const demoUser = {
        id: -1,
        email,
        password: '',
        name: 'Demo User',
      } as any;

      const payload = { sub: demoUser.id, email: demoUser.email };
      const token = jwt.sign(
        payload,
        process.env.JWT_SECRET || 'local_secret_key',
        {
          expiresIn: '7d',
        },
      );

      return {
        access_token: token,
        user: demoUser,
      };
    }

    const user = await this.validateUser(email, password);

    const payload = { sub: user.id, email: user.email };
    const token = jwt.sign(
      payload,
      process.env.JWT_SECRET || 'local_secret_key',
      {
        expiresIn: '7d',
      },
    );

    return {
      access_token: token,
      user,
    };
  }
}
