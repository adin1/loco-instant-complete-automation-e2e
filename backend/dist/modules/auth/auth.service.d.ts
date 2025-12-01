export declare class AuthService {
    private prisma;
    register(email: string, password: string, name?: string): Promise<{
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
    validateUser(email: string, password: string): Promise<{
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
    login(email: string, password: string): Promise<{
        access_token: string;
        user: any;
    }>;
}
