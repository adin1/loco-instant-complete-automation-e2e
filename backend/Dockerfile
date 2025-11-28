# Build stage
FROM node:22-alpine AS builder
WORKDIR /app

# Copiem package.json pentru instalare
COPY package*.json ./
RUN npm install

# Copiem restul codului
COPY . .

# Copiem schema Prisma din rădăcină
COPY ../prisma ./prisma

# Generăm clientul Prisma
RUN npx prisma generate

# Build (dacă ai TypeScript)
RUN npm run build || echo "No build script found"

# Production stage
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production

# Copiem doar ce e necesar
COPY --from=builder /app/package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

CMD ["node", "dist/main.js"]
