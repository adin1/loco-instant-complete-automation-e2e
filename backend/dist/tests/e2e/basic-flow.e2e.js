"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const pg_1 = require("pg");
const dotenv_1 = require("dotenv");
dotenv_1.default.config();
const db = new pg_1.Client({
    connectionString: process.env.DATABASE_URL,
});
describe('Loco Instant – E2E Flow', () => {
    beforeAll(async () => {
        await db.connect();
    });
    afterAll(async () => {
        await db.end();
    });
    it('should create an order and assign a provider', async () => {
        const tenant = await db.query(`SELECT id FROM tenants WHERE code='cluj' LIMIT 1;`);
        expect(tenant.rowCount).toBe(1);
        const tenantId = tenant.rows[0].id;
        const customer = await db.query(`SELECT id FROM users WHERE role='customer' AND tenant_id=$1 LIMIT 1;`, [tenantId]);
        const provider = await db.query(`SELECT id FROM providers WHERE tenant_id=$1 LIMIT 1;`, [tenantId]);
        expect(customer.rowCount).toBe(1);
        expect(provider.rowCount).toBeGreaterThan(0);
        const order = await db.query(`INSERT INTO orders (tenant_id, customer_id, provider_id, service_id, status, price_estimate, origin_geom)
       VALUES ($1, $2, $3, (SELECT id FROM services WHERE slug='croitorie'), 'pending', 90,
               ST_GeogFromText('SRID=4326;POINT(23.62 46.77)'))
       RETURNING id;`, [tenantId, customer.rows[0].id, provider.rows[0].id]);
        expect(order.rows.length).toBe(1);
        const orderId = order.rows[0].id;
        await db.query(`UPDATE orders SET status='assigned' WHERE id=$1;`, [orderId]);
        const statusCheck = await db.query(`SELECT status FROM orders WHERE id=$1;`, [orderId]);
        expect(statusCheck.rows[0].status).toBe('assigned');
        await db.query(`INSERT INTO reviews (tenant_id, order_id, rating, comment)
       VALUES ($1, $2, 5, 'Serviciu excelent!');`, [tenantId, orderId]);
        const review = await db.query(`SELECT rating FROM reviews WHERE order_id=$1;`, [orderId]);
        expect(review.rows[0].rating).toBe(5);
    });
});
//# sourceMappingURL=basic-flow.e2e.js.map