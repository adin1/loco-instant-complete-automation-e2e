"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const pg_1 = require("pg");
const dotenv_1 = require("dotenv");
dotenv_1.default.config();
const db = new pg_1.Client({
    connectionString: process.env.DATABASE_URL,
});
async function main() {
    await db.connect();
    console.log('🧹 Curățare date demo pentru tenant: Cluj...');
    const tenant = await db.query(`SELECT id FROM tenants WHERE code='cluj' LIMIT 1;`);
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
//# sourceMappingURL=reset-demo.js.map