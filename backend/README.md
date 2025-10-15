# Loco Instant – Backend (NestJS)

## Quickstart (Local)
```bash
cp .env.example .env
# completează variabilele
npm i -g pnpm || true
pnpm i
pnpm dev
# Swagger: http://localhost:3000/api/docs
```

## SQL în Supabase
Execută, în ordine, în SQL Editor:
1. `sql/schema.sql`
2. `sql/partitions.sql`
3. `sql/seed.sql`

## OpenSearch
În consola OpenSearch (Dev Tools):
- trimite `opensearch/templates/providers.json`
- `opensearch/templates/orders.json`
- `opensearch/aliases.json`

## Worker
```bash
pnpm worker
```

## Endpoints
- POST `/auth/signup` `{ email, password }`
- POST `/auth/login` `{ email, password }`
- POST `/orders`
- GET  `/providers/:id`
- GET  `/providers/:id/status`
- POST `/providers/:id/status`
- GET  `/search/providers?q=...&lat=...&lon=...&radius=5km`