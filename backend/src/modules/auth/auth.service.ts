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
    // Clienți
    { id: 1, email: 'client@test.ro', name: 'Ion Popescu', role: 'customer' },
    { id: 2, email: 'maria@test.ro', name: 'Maria Ionescu', role: 'customer' },
    { id: 3, email: 'alex@test.ro', name: 'Alexandru Radu', role: 'customer' },
    { id: 4, email: 'elena@test.ro', name: 'Elena Munteanu', role: 'customer' },
    { id: 5, email: 'adinatraica@gmail.com', name: 'Adina Traica', role: 'customer' },
    { id: 6, email: 'mihadina@yahoo.com', name: 'Mihadina', role: 'provider' },
    // Prestatori
    { id: 10, email: 'instalator1@test.ro', name: 'Vasile Mureșan', role: 'provider' },
    { id: 11, email: 'instalator2@test.ro', name: 'Florin Popa', role: 'provider' },
    { id: 12, email: 'electrician1@test.ro', name: 'Mihai Electricul', role: 'provider' },
    { id: 13, email: 'electrician2@test.ro', name: 'Dan Volt', role: 'provider' },
    { id: 14, email: 'curatenie1@test.ro', name: 'Maria Clean', role: 'provider' },
    { id: 15, email: 'curatenie2@test.ro', name: 'Ana Curățel', role: 'provider' },
    { id: 16, email: 'lacatus1@test.ro', name: 'Andrei Lăcătușul', role: 'provider' },
    { id: 17, email: 'transport1@test.ro', name: 'George Transport', role: 'provider' },
    { id: 18, email: 'zugrav1@test.ro', name: 'Dan Zugravu', role: 'provider' },
    { id: 19, email: 'it1@test.ro', name: 'Radu TechFix', role: 'provider' },
    { id: 20, email: 'prestator@test.ro', name: 'Prestator Demo', role: 'provider' },
    // Admin
    { id: 100, email: 'admin@test.ro', name: 'Admin LOCO', role: 'admin' },
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
      // Permite login cu utilizatori demo (inclusiv în producție pentru demo)
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
          console.log(`[FALLBACK] Login for: ${email}`);
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
        console.log('[FALLBACK] Database not available');
      }

      // Re-throw UnauthorizedException as-is, wrap other errors
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException('Email sau parolă incorectă');
    }
  }
}
