export declare class AuthService {
    private prisma;
    register(email: string, password: string, name?: string): Promise<{
        name: string | null;
        id: number;
        email: string;
        password: string;
        createdAt: Date;
    }>;
    validateUser(email: string, password: string): Promise<{
        name: string | null;
        id: number;
        email: string;
        password: string;
        createdAt: Date;
    }>;
    login(email: string, password: string): Promise<{
        access_token: string;
        user: any;
    }>;
}
