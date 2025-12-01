export declare class AuthService {
    private prisma;
    register(email: string, password: string, name?: string): Promise<{
        id: bigint;
        role: string;
        phone_e164: string | null;
        email: string | null;
        password_hash: string | null;
        createdAt: Date;
        updatedAt: Date;
        password: string | null;
        name: string | null;
        tenant_id: bigint;
    }>;
    validateUser(email: string, password: string): Promise<{
        id: bigint;
        role: string;
        phone_e164: string | null;
        email: string | null;
        password_hash: string | null;
        createdAt: Date;
        updatedAt: Date;
        password: string | null;
        name: string | null;
        tenant_id: bigint;
    }>;
    login(email: string, password: string): Promise<{
        access_token: string;
        user: any;
    }>;
}
