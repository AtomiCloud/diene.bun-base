# Multi-stage Bun build. The build stage installs pinned dependencies and
# bundles the neutral sample entrypoint to dist/index.js (the same artifact as
# `bun run build` / scripts/ci/build.sh). The runtime stage ships only that
# bundle on the slim Bun image and runs it.
#
# Downstream templates adapt the ENTRYPOINT (and any extra runtime files) to
# their own service entrypoint.
FROM oven/bun:1-alpine AS build
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY tsconfig.json ./
COPY src ./src
# Delegate to the package.json `build` script so the build command stays a single
# source of truth (package.json) instead of being re-hardcoded in the image.
RUN bun run build

FROM oven/bun:1-alpine AS runtime
WORKDIR /app
COPY --from=build /app/dist ./dist
ENTRYPOINT ["bun", "dist/index.js"]
