import { Injectable } from '@nestjs/common';
import { createClient } from '@supabase/supabase-js';

@Injectable()
export class AuthService {
  private supabase = createClient(process.env.SUPABASE_URL!, process.env.SUPABASE_ANON_KEY!);
  signup(email: string, password: string) { return this.supabase.auth.signUp({ email, password }); }
  login(email: string, password: string) { return this.supabase.auth.signInWithPassword({ email, password }); }
}