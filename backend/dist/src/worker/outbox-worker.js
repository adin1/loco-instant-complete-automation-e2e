"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const opensearch_1 = require("@opensearch-project/opensearch");
const pg_1 = require("pg");
const os = new opensearch_1.Client({ node: process.env.OS_NODE, auth: { username: process.env.OS_USERNAME, password: process.env.OS_PASSWORD }, ssl: { rejectUnauthorized: false } });
const pg = new pg_1.Pool({
    host: process.env.PG_HOST,
    port: Number(process.env.PG_PORT || 5432),
    database: process.env.PG_DATABASE,
    user: process.env.PG_USER,
    password: process.env.PG_PASSWORD,
    ssl: process.env.PG_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
});
async function loop() {
    const client = await pg.connect();
    try {
        await client.query(`select set_config('app.tenant_id', (select id::text from tenants where code=$1), true)`, [process.env.TENANT_CODE || 'cluj']);
        const { rows } = await client.query(`
      select id, event_type, payload from order_events
      where created_at > now() - interval '1 day' and event_type in ('provider_upserted','order_created')
      order by id asc limit 100`);
        if (rows.length) {
            const body = [];
            for (const ev of rows) {
                if (ev.event_type === 'provider_upserted') {
                    const p = ev.payload;
                    body.push({ index: { _index: 'loco_providers', _id: String(p.provider_id) } });
                    body.push({ tenant_code: process.env.TENANT_CODE || 'cluj', ...p });
                }
            }
            if (body.length) {
                await os.bulk({ body });
            }
        }
    }
    finally {
        client.release();
    }
}
(async () => {
    console.log('Outbox worker started');
    setInterval(loop, 1000);
})();
//# sourceMappingURL=outbox-worker.js.map