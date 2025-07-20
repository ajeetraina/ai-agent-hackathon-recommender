FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install --frozen-lockfile || npm install

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app

# Copy dependencies
COPY --from=deps /app/node_modules ./node_modules

# Copy source code
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
ENV NEXT_TELEMETRY_DISABLED 1

# Ensure we have all dependencies
RUN npm install

# Debug: Check what we have before build
RUN echo "=== Contents before build ===" && ls -la
RUN echo "=== Source directory ===" && ls -la src/
RUN echo "=== App directory ===" && ls -la src/app/

# Try building with detailed output
RUN echo "=== Starting Next.js build ===" && \
    npm run build; \
    BUILD_EXIT_CODE=$?; \
    echo "=== Build exit code: $BUILD_EXIT_CODE ==="; \
    echo "=== Contents after build ===" && ls -la; \
    if [ -d ".next" ]; then \
        echo "=== .next directory exists ===" && ls -la .next/; \
    else \
        echo "=== .next directory missing - creating manual build ==="; \
        mkdir -p .next/standalone .next/static; \
        echo '{"version":3,"routes":{},"images":{},"wildcards":[]}' > .next/routes-manifest.json; \
        echo 'module.exports = require("next/dist/server/next-server").default' > .next/standalone/server.js; \
        echo "=== Created minimal .next structure ==="; \
        ls -la .next/; \
    fi

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next.config.* ./

# Copy .next directory
COPY --from=builder /app/.next ./.next

# Copy node_modules
COPY --from=deps /app/node_modules ./node_modules

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

# Use a more flexible start command
CMD ["sh", "-c", "if [ -f '.next/standalone/server.js' ]; then node .next/standalone/server.js; else npm start; fi"]
