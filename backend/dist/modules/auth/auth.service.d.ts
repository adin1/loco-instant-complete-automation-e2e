export declare class AuthService {
    private prisma;
    register(email: string, password: string, name?: string): Promise<{
        name: string | null;
        id: bigint;
        tenant_id: bigint;
        role: string;
        phone_e164: string | null;
        email: string | null;
        password_hash: string | null;
        createdAt: Date;
        updatedAt: Date;
        password: string | null;
    }>;
    validateUser(email: string, password: string): Promise<{
        name: string | null;
        id: bigint;
        tenant_id: bigint;
        role: string;
        phone_e164: string | null;
        email: string | null;
        password_hash: string | null;
        createdAt: Date;
        updatedAt: Date;
        password: string | null;
    }>;
    login(email: string, password: string): Promise<{
        access_token: string;
        user: any;
    }>;
}
