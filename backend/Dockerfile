FROM node:20-alpine as build
WORKDIR /app
COPY package.json pnpm-lock.yaml* package-lock.json* ./
RUN npm i -g pnpm || true && (pnpm i --frozen-lockfile || npm ci)
COPY . .
RUN (pnpm build || npm run build)

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/package.json /app/pnpm-lock.yaml* /app/package-lock.json* ./
RUN npm i -g pnpm || true && (pnpm i --prod --frozen-lockfile || npm ci --omit=dev)
COPY --from=build /app/dist ./dist
CMD ["node","dist/main.js"]