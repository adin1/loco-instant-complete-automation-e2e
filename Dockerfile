# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Copy backend files
COPY backend/package*.json ./
RUN npm install

# Copy prisma schema and generate client
COPY prisma ./prisma
RUN npx prisma generate

COPY backend/ .

# Build
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/dist ./dist

EXPOSE 10000
CMD ["node", "dist/main.js"]

