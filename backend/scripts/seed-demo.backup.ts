/**
 * Loco Instant – Seed Demo Data
 * Populează DB cu tenantul Cluj, servicii, prestatori, clienți și comenzi.
 */

import { Client } from 'pg';
import * as dotenv from 'dotenv';


dotenv.config();

const db = new Client({
  connectionString: process.env.DATABASE_URL,
});

async function main() {
  await db.connect();
  console.log('🌱 Seeding database for tenant: Cluj...');

  const tenant = await db.query(
    `INSERT INTO tenants (code, name, tz)
     VALUES ('cluj', 'Cluj-Napoca', 'Europe/Bucharest')
     ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name
     RETURNING id;`,
  );
  const tenantId = tenant.rows[0].id;

  const services = ['croitorie', 'menaj', 'auto'];
  for (const s of services) {
    await db.query(
      `INSERT INTO services (tenant_id, slug, name)
       VALUES ($1, $2, $3)
       ON CONFLICT (slug) DO NOTHING;`,
      [tenantId, s, s.charAt(0).toUpperCase() + s.slice(1)],
    );
  }

  const users = [
    { role: 'provider', phone: '+40740123456', email: 'maria@atelier.ro' },
    { role: 'provider', phone: '+40740222222', email: 'ion@autoexpert.ro' },
    { role: 'customer', phone: '+40740333333', email: 'ana@client.ro' },
  ];
  for (const u of users) {
    await db.query(
      `INSERT INTO users (tenant_id, role, phone_e164, email, password_hash)
       VALUES ($1, $2, $3, $4, 'demo_hash')
       ON CONFLICT (email) DO NOTHING;`,
      [tenantId, u.role, u.phone, u.email],
    );
  }

  const providers = await db.query(
    `INSERT INTO providers (tenant_id, user_id, display_name, is_verified, rating_avg, rating_count)
     SELECT $1, id,
            CASE
              WHEN email='maria@atelier.ro' THEN 'Atelier Maria'
              WHEN email='ion@autoexpert.ro' THEN 'AutoExpert Ion'
              ELSE email
            END,
            TRUE, ROUND(random()*2 + 3,2), (random()*100)::int
       FROM users WHERE role='provider' AND tenant_id=$1
     ON CONFLICT DO NOTHING
     RETURNING id, display_name;`,
    [tenantId],
  );

  for (const p of providers.rows) {
    await db.query(
      `INSERT INTO order_events (tenant_id, order_id, event_type, payload)
       VALUES ($1, NULL, 'provider_upserted',
               jsonb_build_object('provider_id', $2, 'name', $3, 'tenant_code', 'cluj',
                                  'service_ids', ARRAY['croitorie'], 'service_names', ARRAY['Croitorie'],
                                  'rating_avg', 4.8, 'rating_count', 127,
                                  'is_instant', true,
                                  'location', jsonb_build_object('lat', 46.77, 'lon', 23.62),
                                  'updated_at', to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS"Z"')))
      );`,
      [tenantId, p.id, p.display_name],
    );
  }

  const customer = await db.query(
    `SELECT id FROM users WHERE email='ana@client.ro' LIMIT 1;`,
  );
  const customerId = customer.rows[0].id;
  const providerId = providers.rows[0].id;

  await db.query(
    `INSERT INTO orders (tenant_id, customer_id, provider_id, service_id, status, price_estimate, origin_geom)
     VALUES ($1, $2, $3, (SELECT id FROM services WHERE slug='croitorie'),
             'assigned', 120, ST_GeogFromText('SRID=4326;POINT(23.62 46.77)'));`,
    [tenantId, customerId, providerId],
  );

  console.log('✅ Seed complet. Verifică tabelele și workerul.');
  await db.end();
}

main().catch((err) => {
  console.error('❌ Seed error:', err);
  process.exit(1);
});
