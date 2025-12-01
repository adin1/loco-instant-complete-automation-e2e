/**
 * Script pentru crearea conturilor de test
 * Rulează cu: npx ts-node scripts/create-test-accounts.ts
 */

import { Client } from 'pg';
import * as bcrypt from 'bcrypt';
import * as dotenv from 'dotenv';

dotenv.config();

const db = new Client({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5433/loco?schema=public',
});

interface TestAccount {
  email: string;
  password: string;
  name: string;
  role: 'customer' | 'provider';
  phone?: string;
}

const testAccounts: TestAccount[] = [
  // ========== CLIENȚI ==========
  { email: 'client1@test.ro', password: 'test123', name: 'Ana Popescu', role: 'customer', phone: '+40740111111' },
  { email: 'client2@test.ro', password: 'test123', name: 'Ion Ionescu', role: 'customer', phone: '+40740111112' },
  { email: 'client3@test.ro', password: 'test123', name: 'Maria Dumitrescu', role: 'customer', phone: '+40740111113' },
  
  // ========== PRESTATORI ==========
  { email: 'prestator1@test.ro', password: 'test123', name: 'Electrician Pro - Vasile', role: 'provider', phone: '+40740222221' },
  { email: 'prestator2@test.ro', password: 'test123', name: 'Curățenie Expert - Elena', role: 'provider', phone: '+40740222222' },
  { email: 'prestator3@test.ro', password: 'test123', name: 'Instalator Rapid - George', role: 'provider', phone: '+40740222223' },
];

async function main() {
  await db.connect();
  console.log('🔧 Creez conturi de test...\n');

  // Asigură-te că există tenant-ul
  const tenant = await db.query(
    `INSERT INTO tenants (code, name, tz)
     VALUES ('cluj', 'Cluj-Napoca', 'Europe/Bucharest')
     ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name
     RETURNING id;`
  );
  const tenantId = tenant.rows[0].id;

  console.log('📋 CONTURI DE TEST CREATE:\n');
  console.log('═'.repeat(60));
  console.log('  CLIENȚI:');
  console.log('═'.repeat(60));

  for (const account of testAccounts) {
    const hashedPassword = await bcrypt.hash(account.password, 10);
    
    try {
      await db.query(
        `INSERT INTO users (tenant_id, email, password, name, role, phone_e164)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (email) DO UPDATE SET 
           password = EXCLUDED.password,
           name = EXCLUDED.name,
           role = EXCLUDED.role
         RETURNING id;`,
        [tenantId, account.email, hashedPassword, account.name, account.role, account.phone]
      );

      const icon = account.role === 'customer' ? '👤' : '🔧';
      const roleLabel = account.role === 'customer' ? 'CLIENT' : 'PRESTATOR';
      
      if (account.role === 'provider' && testAccounts.filter(a => a.role === 'provider')[0] === account) {
        console.log('═'.repeat(60));
        console.log('  PRESTATORI:');
        console.log('═'.repeat(60));
      }
      
      console.log(`  ${icon} ${account.name}`);
      console.log(`     Email: ${account.email}`);
      console.log(`     Parolă: ${account.password}`);
      console.log('');
      
    } catch (err: any) {
      console.log(`  ❌ Eroare la ${account.email}: ${err.message}`);
    }
  }

  console.log('═'.repeat(60));
  console.log('\n✅ Toate conturile au fost create cu succes!');
  console.log('\n💡 Folosește oricare din conturile de mai sus pentru a te autentifica.');
  console.log('   Parola pentru toate: test123\n');

  await db.end();
}

main().catch((err) => {
  console.error('❌ Eroare:', err);
  process.exit(1);
});

