# Configurare variabile de mediu pentru Worker

## 📋 Variabile necesare

- `DATABASE_URL` - Connection string PostgreSQL
- `REDIS_URL` - Connection string Redis
- `NODE_ENV` - Environment (development/production)

---

## 🏠 Pentru Development Local

### Opțiunea 1: Docker Compose (Recomandat)

1. **Pornește serviciile locale:**
   ```powershell
   cd backend
   docker-compose -f docker-compose.local.yml up -d
   ```

2. **Folosește aceste valori:**
   ```env
   DATABASE_URL=postgresql://postgres:postgres@localhost:5432/loco
   REDIS_URL=redis://localhost:6379
   NODE_ENV=development
   ```

### Opțiunea 2: Servicii externe (Railway/Neon/Upstash)

Dacă ai deja servicii configurate pe Railway, folosește valorile de acolo.

---

## 🚀 Pentru Producție (Railway/Neon/Upstash)

### DATABASE_URL (PostgreSQL)

#### Opțiunea A: Neon (Recomandat pentru PostgreSQL)
1. Mergi pe https://console.neon.tech/
2. Selectează proiectul tău
3. Click pe **"Connection Details"**
4. Copiază **"Connection string"** (format: `postgresql://user:password@host/database?sslmode=require`)

#### Opțiunea B: Railway (PostgreSQL)
1. Mergi pe https://railway.app/
2. Selectează proiectul → **PostgreSQL service**
3. Click pe **"Variables"** tab
4. Găsește `DATABASE_URL` sau construiește-l din:
   - `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`

#### Opțiunea C: Supabase (vezi fișierul `backend/Service Role key.env`)
- Format: `postgresql://postgres:password@host:5432/postgres`
- Înlocuiește `your-project.supabase.co` cu host-ul real din Supabase Dashboard

### REDIS_URL

#### Opțiunea A: Upstash (Recomandat pentru Redis)
1. Mergi pe https://console.upstash.com/
2. Selectează proiectul → **Redis Database**
3. Click pe **"REST API"** sau **"Redis CLI"**
4. Copiază **"Endpoint URL"** (format: `redis://default:password@host:port`)

#### Opțiunea B: Railway (Redis)
1. Mergi pe https://railway.app/
2. Selectează proiectul → **Redis service**
3. Click pe **"Variables"** tab
4. Găsește `REDIS_URL` sau construiește-l din variabilele disponibile

---

## 🐳 Rulare Docker Container

### Development Local
```powershell
docker run --rm `
  -e NODE_ENV=development `
  -e DATABASE_URL="postgresql://postgres:postgres@host.docker.internal:5432/loco" `
  -e REDIS_URL="redis://host.docker.internal:6379" `
  -p 3001:3001 `
  loco-worker:latest
```

**Notă:** `host.docker.internal` permite container-ului să acceseze serviciile de pe host.

### Producție
```powershell
docker run --rm `
  -e NODE_ENV=production `
  -e DATABASE_URL="postgresql://user:pass@neon-host/database?sslmode=require" `
  -e REDIS_URL="redis://default:pass@upstash-host:port" `
  -p 3001:3001 `
  loco-worker:latest
```

---

## ✅ Verificare

După ce ai setat variabilele, verifică că worker-ul pornește corect:
```powershell
docker run --rm `
  -e NODE_ENV=development `
  -e DATABASE_URL="postgresql://postgres:postgres@host.docker.internal:5432/loco" `
  -e REDIS_URL="redis://host.docker.internal:6379" `
  loco-worker:latest
```

Ar trebui să vezi:
- ✅ Connected to Redis
- ✅ Worker started on port 3001

---

## 🔗 Link-uri utile

- **Neon Dashboard:** https://console.neon.tech/
- **Upstash Dashboard:** https://console.upstash.com/
- **Railway Dashboard:** https://railway.app/
- **Supabase Dashboard:** https://app.supabase.com/

