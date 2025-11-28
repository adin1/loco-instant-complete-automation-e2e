FROM node:22-alpine AS builder
WORKDIR /app

COPY worker/package*.json ./
RUN npm install
COPY worker ./
COPY prisma ./prisma
RUN npx prisma generate
RUN npm run build || echo "No build script found"

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

CMD ["node", "dist/main.js"]
