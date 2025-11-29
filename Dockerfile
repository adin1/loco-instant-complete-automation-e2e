# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Copy everything needed for backend
COPY backend/package*.json ./
COPY backend/tsconfig*.json ./
COPY backend/nest-cli.json ./
COPY backend/src ./src
COPY prisma ./prisma

# Install dependencies
RUN npm install
RUN npm install prisma@5 @prisma/client@5

# Generate Prisma client
RUN npx prisma generate

# Build the app
RUN npm run build

# Verify build output
RUN ls -la dist/ || echo "No dist folder!"

# Production stage
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=10000

# Install OpenSSL for Prisma
RUN apk add --no-cache openssl openssl-dev

# Copy package files and install production deps
COPY --from=builder /app/package*.json ./
RUN npm install --omit=dev

# Copy prisma schema and regenerate client
COPY --from=builder /app/prisma ./prisma
RUN npm install prisma@5 @prisma/client@5
RUN npx prisma generate

# Copy built app
COPY --from=builder /app/dist ./dist

EXPOSE 10000
CMD ["node", "dist/main.js"]
