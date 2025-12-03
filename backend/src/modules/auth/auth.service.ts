import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
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
      throw new ConflictException('User already exists');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await this.prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name: name || email.split('@')[0],
        tenant_id: BigInt(1),
        role: 'customer',
      },
    });

    return {
      id: Number(newUser.id),
      email: newUser.email,
      name: newUser.name,
      role: newUser.role,
    };
  }

  // Validează email + parolă
  async validateUser(email: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new UnauthorizedException('Email sau parolă incorectă');
    }

    // Verifică parola cu bcrypt
    if (user.password) {
      const isMatch = await bcrypt.compare(password, user.password);
      if (isMatch) {
        return user;
      }
    }

    // Fallback: verifică și în password_hash dacă există
    if (user.password_hash) {
      const isMatch = await bcrypt.compare(password, user.password_hash);
      if (isMatch) {
        return user;
      }
    }

    throw new UnauthorizedException('Email sau parolă incorectă');
  }

  // Helper pentru a converti user la format serializabil
  private serializeUser(user: any) {
    return {
      id: Number(user.id),
      email: user.email,
      name: user.name,
      role: user.role,
    };
  }

  // Demo users pentru când nu există bază de date
  private demoUsers = [
    { id: 1, email: 'client@test.ro', name: 'Client Demo', role: 'customer' },
    { id: 2, email: 'prestator@test.ro', name: 'Prestator Demo', role: 'provider' },
    { id: 3, email: 'admin@test.ro', name: 'Admin Demo', role: 'admin' },
    { id: 4, email: 'adinatraica@gmail.com', name: 'Adina Traica', role: 'customer' },
  ];

  // Login + generare token JWT
  async login(email: string, password: string) {
    try {
      // Încearcă autentificarea normală
      const user = await this.validateUser(email, password);
      const userId = Number(user.id);

      const payload = { sub: userId, email: user.email };
      const token = jwt.sign(
        payload,
        process.env.JWT_SECRET || 'local_secret_key',
        { expiresIn: '7d' },
      );

      return {
        access_token: token,
        user: this.serializeUser(user),
      };
    } catch (error) {
      // În development/demo mode, permite login cu utilizatori demo
      if (process.env.NODE_ENV !== 'production') {
        // Verifică dacă e un utilizator demo
        const demoUser = this.demoUsers.find(u => u.email.toLowerCase() === email.toLowerCase());
        
        if (demoUser) {
          console.log(`[DEMO MODE] Login for demo user: ${email}`);
          
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

        // Fallback: încearcă să găsească în baza de date (dacă e disponibilă)
        try {
          const user = await this.prisma.user.findUnique({ where: { email } });
          
          if (user) {
            console.log(`[DEV MODE] Login fallback for: ${email}`);
            const userId = Number(user.id);
            
            const payload = { sub: userId, email: user.email };
            const token = jwt.sign(
              payload,
              process.env.JWT_SECRET || 'local_secret_key',
              { expiresIn: '7d' },
            );

            return {
              access_token: token,
              user: this.serializeUser(user),
            };
          }
        } catch (dbError) {
          console.log('[DEV MODE] Database not available, using demo mode only');
        }
      }

      // Re-throw UnauthorizedException as-is, wrap other errors
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException('Email sau parolă incorectă');
    }
  }
}
