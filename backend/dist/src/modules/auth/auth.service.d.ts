export declare class AuthService {
    private prisma;
    register(email: string, password: string, name?: string): Promise<{
        email: string;
        password: string;
        name: string | null;
        createdAt: Date;
        id: number;
    }>;
    validateUser(email: string, password: string): Promise<{
        email: string;
        password: string;
        name: string | null;
        createdAt: Date;
        id: number;
    }>;
    login(email: string, password: string): Promise<{
        access_token: string;
        user: any;
    }>;
}
