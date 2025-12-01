import { AuthService } from './auth.service';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    register(body: {
        email: string;
        password: string;
        name?: string;
    }): Promise<{
        name: string | null;
        id: number;
        email: string;
        password: string;
        phone: string | null;
        role: import(".prisma/client").$Enums.UserRole;
        rating: number | null;
        createdAt: Date;
        updatedAt: Date;
    }>;
    login(body: {
        email: string;
        password: string;
    }): Promise<{
        access_token: string;
        user: any;
    }>;
}
