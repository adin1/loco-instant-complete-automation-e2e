import { AuthService } from './auth.service';
export declare class AuthController {
    private readonly auth;
    constructor(auth: AuthService);
    signup(dto: {
        email: string;
        password: string;
    }): Promise<import("@supabase/supabase-js").AuthResponse>;
    login(dto: {
        email: string;
        password: string;
    }): Promise<import("@supabase/supabase-js").AuthTokenResponsePassword>;
}
