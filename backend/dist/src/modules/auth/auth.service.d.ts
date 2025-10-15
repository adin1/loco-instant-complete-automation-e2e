export declare class AuthService {
    private supabase;
    signup(email: string, password: string): Promise<import("@supabase/supabase-js").AuthResponse>;
    login(email: string, password: string): Promise<import("@supabase/supabase-js").AuthTokenResponsePassword>;
}
