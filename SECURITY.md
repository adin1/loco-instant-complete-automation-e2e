# 🔒 LOCO INSTANT - GHID DE SECURITATE

## Prezentare generală

Acest document descrie măsurile de securitate implementate în platforma LOCO Instant.

---

## 1. Autentificare și Autorizare

### JWT (JSON Web Tokens)
- Tokeni semnați cu HMAC-SHA256
- Expirare: 7 zile
- Secret key: minim 256 biți
- Token refresh implementat

### Parole
- Hash: bcrypt cu 10 runde salt
- Lungime minimă: 6 caractere (recomandat: 12+)
- Validare complexitate în frontend

---

## 2. Baza de Date

### PostgreSQL
- Conexiuni criptate (SSL în producție)
- Autentificare SCRAM-SHA-256
- Row-Level Security activat pe tabele sensibile
- Audit logging pentru users și payments

### Backup
- Script automat: `backup.ps1`
- Git tags pentru restore points
- Backup local în `C:\Users\Home\loco-instant-backups`

---

## 3. Rate Limiting

### API
- 100 cereri / minut per IP
- Blocare după 5 încercări de login eșuate în 15 minute
- Deblocare automată după 15 minute

### Implementare
```javascript
// În main.ts sau middleware
app.use(rateLimit({
  windowMs: 60 * 1000, // 1 minut
  max: 100, // 100 cereri
}));
```

---

## 4. CORS (Cross-Origin Resource Sharing)

Origini permise (producție):
- https://loco-instant.ro
- https://www.loco-instant.ro

---

## 5. Headers de Securitate

```javascript
// Implementat în NestJS
app.use(helmet());

// Headers configurate:
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- Strict-Transport-Security: max-age=31536000
- Content-Security-Policy
```

---

## 6. Validare și Sanitizare

### Input Validation
- DTOs cu class-validator în NestJS
- Sanitizare HTML pentru prevenire XSS
- Parametri tip BigInt convertit la Number

### SQL Injection
- Prisma ORM cu queries parametrizate
- Fără raw SQL queries nevalidate

---

## 7. Configurare Docker Securizată

Folosește `docker-compose.secure.yml` pentru producție:

```bash
# Setează variabilele de mediu
export DB_PASSWORD="ParolaFoarteComplexa123!"
export REDIS_PASSWORD="AltaParolaComplexa456!"
export JWT_SECRET="SecretJWT256BitsMinimum789!"

# Pornește serviciile
docker-compose -f docker-compose.secure.yml up -d
```

---

## 8. Variabile de Mediu (Producție)

```env
# .env.production (NU include în Git!)
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@localhost:5432/loco_production
REDIS_URL=redis://:password@localhost:6379
JWT_SECRET=minimum-256-bit-secret-key
CORS_ORIGINS=https://loco-instant.ro
```

---

## 9. Audit și Monitoring

### Audit Log
Tabela `audit_log` înregistrează:
- Modificări în `users`
- Modificări în `payments`
- Timestamp și date vechi/noi

### Sesiuni
Tabela `user_sessions` gestionează:
- Tokeni activi
- IP-uri și User-Agent
- Expirare și revocare

---

## 10. Recomandări pentru Producție

### Checklist înainte de deploy:
- [ ] Schimbă toate parolele default
- [ ] Activează HTTPS (SSL/TLS)
- [ ] Configurează firewall
- [ ] Setează backup automat
- [ ] Activează monitoring/alerting
- [ ] Testează restore din backup
- [ ] Revizuiește permisiunile utilizatori DB

### Comenzi utile:

```bash
# Backup manual
.\backup.ps1 backup

# Listează backup-uri
.\backup.ps1 list

# Restaurează
.\backup.ps1 restore backup-2025-12-01-1924

# Verifică containerele
docker-compose -f docker-compose.secure.yml ps

# Logs
docker-compose -f docker-compose.secure.yml logs -f backend
```

---

## 11. Raportare Vulnerabilități

Dacă descoperi o vulnerabilitate de securitate:
1. NU o face publică
2. Contactează: security@loco-instant.ro
3. Oferă detalii clare și pași de reproducere

---

## Versiune
- Document creat: 2025-12-01
- Ultima actualizare: 2025-12-01

