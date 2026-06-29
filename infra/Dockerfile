FROM oven/bun:1-alpine AS build
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY tsconfig.json ./
COPY src ./src
RUN bun build ./src/index.ts --outdir ./dist --target bun

FROM oven/bun:1-alpine AS runtime
WORKDIR /app
COPY --from=build /app/dist ./dist
ENTRYPOINT ["bun", "dist/index.js"]
