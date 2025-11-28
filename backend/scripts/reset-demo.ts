/**
 * Loco Instant – Reset Demo Data
 * Șterge toate datele demo pentru tenantul 'cluj'
 * Fără a distruge schema sau alte orașe.
 */

import { Client } from 'pg';
import * as dotenv from 'dotenv';

dotenv.config();

const db = new Client({
  connectionString: process.env.DATABASE_URL,
});

async function main() {
  await db.connect();
  console.log('🧹 Curățare date demo pentru tenant: Cluj...');

  const tenant = await db.query(
    `SELECT id FROM tenants WHERE code='cluj' LIMIT 1;`
  );
  if (tenant.rowCount === 0) {
    console.log('⚠️ Tenantul Cluj nu există, nimic de șters.');
    await db.end();
    return;
  }
  const tenantId = tenant.rows[0].id;

  const tables = [
    'order_events',
    'order_items',
    'orders',
    'reviews',
    'payments',
    'provider_availability',
    'provider_services',
    'providers',
    'users',
    'services'
  ];

  for (const t of tables) {
    await db.query(`DELETE FROM ${t} WHERE tenant_id = $1;`, [tenantId]);
  }

  console.log('✅ Date demo pentru Cluj șterse complet.');

  await db.query(`UPDATE tenants SET is_active = TRUE WHERE id = $1;`, [tenantId]);

  await db.end();
}

main().catch((err) => {
  console.error('❌ Reset error:', err);
  process.exit(1);
});
