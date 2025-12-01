export declare class AuthService {
    private prisma;
    register(email: string, password: string, name?: string): Promise<{
        id: number;
        email: string;
        name: string;
        role: string;
    }>;
    validateUser(email: string, password: string): Promise<{
        name: string | null;
        password: string | null;
        id: bigint;
        role: string;
        tenant_id: bigint;
        phone_e164: string | null;
        email: string | null;
        password_hash: string | null;
        createdAt: Date;
        updatedAt: Date;
    }>;
    private serializeUser;
    login(email: string, password: string): Promise<{
        access_token: string;
        user: {
            id: number;
            email: any;
            name: any;
            role: any;
        };
    }>;
}
