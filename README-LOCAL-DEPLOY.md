# LOCO Instant — Setup local & deploy

Acest ghid te ajută să pornești aplicația local (Docker) și să o publici în GitHub + CI/CD (Railway & Render).

## 1) Cerințe
- Docker Desktop (sau Docker Engine)
- Node.js 18+ (recomandat 22 pentru development)
- Git
- Un cont GitHub

## 2) Structură
```
backend/    NestJS + Prisma
worker/     Node.js background jobs
frontend/   Next.js 16 + TailwindCSS 4
docker-compose.yml
.env
```

## 3) .env (LOCAL)
Copiază `.env.example` în `.env`:
```bash
cp .env.example .env
```
Editează variabilele dacă e nevoie.

## 4) Pornește local
```bash
docker compose up -d --build
```
- Backend: http://localhost:3000
- Frontend: http://localhost:3001

Dacă vezi erori de tabele, rulează:
```bash
docker compose exec backend npx prisma migrate deploy
```

## 5) Lucru cu Git & GitHub

### Inițializează repo (dacă nu e deja)
```bash
git init
git add .
git commit -m "chore: initial loco instant setup"
```

### Creează un repo pe GitHub
1. Mergi pe https://github.com/new și creează un repository gol (fără README licență sau .gitignore).
2. Leagă repository-ul local de cel remote:
```bash
git branch -M main
git remote add origin <URL-ul-repo-ului-tau>
git push -u origin main
```

> Exemplu URL: `https://github.com/<user>/<repo>.git` sau `git@github.com:<user>/<repo>.git`

## 6) CI/CD (GitHub Actions)
Fișierul `.github/workflows/ci-and-deploy.yml` este inclus. Setează secretele în GitHub:
- `RAILWAY_TOKEN`
- `RENDER_DEPLOY_HOOK_BACKEND`
- `RENDER_DEPLOY_HOOK_FRONTEND`
- `DATABASE_URL`
- `REDIS_URL`
- `JWT_SECRET`
- (opțional) `NEXT_PUBLIC_API_URL`

După ce faci push pe `main`, pipeline-ul rulează automat.


## 7) Deploy în cloud
- **Railway**: CLI va urca serviciile `backend` și `worker`. Setează variabilele de mediu în Railway.
- **Render**: activează **Deploy Hooks** pentru backend și frontend și adaugă URL-urile ca secrete în GitHub.

## 8) Troubleshooting
- Conexiunea la DB: verifică `DATABASE_URL` (în Docker: host trebuie să fie `db`).
- Frontend → Backend: `NEXT_PUBLIC_API_URL` trebuie să indice URL-ul API.
- Migrații Prisma: `npx prisma migrate deploy` înainte de start, dacă tabelele lipsesc.
