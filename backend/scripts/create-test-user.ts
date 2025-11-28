import 'dotenv/config';
import { AuthService } from '../src/modules/auth/auth.service';

async function main() {
  const auth = new AuthService();

  const email = 'demo@loco-instant.ro';
  const password = 'Parola123!';
  const name = 'Demo User';

  try {
    const user = await auth.register(email, password, name);
    // eslint-disable-next-line no-console
    console.log('Created demo user:', { id: user['id'], email: user['email'] });
  } catch (e: any) {
    // Dacă user-ul există deja, doar afișăm un mesaj prietenos
    // eslint-disable-next-line no-console
    console.error('Could not create demo user:', e?.message ?? e);
  } finally {
    // Forțăm închiderea procesului pentru a nu lăsa conexiuni deschise
    process.exit(0);
  }
}

main().catch((e) => {
  // eslint-disable-next-line no-console
  console.error('Unexpected error while creating demo user:', e);
  process.exit(1);
});


