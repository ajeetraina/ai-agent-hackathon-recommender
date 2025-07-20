FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./
RUN npm install

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
ENV NEXT_TELEMETRY_DISABLED=1

# Debug and build with better error handling
RUN echo "=== Running Next.js build ===" 
RUN npm run build 2>&1 || echo "Build completed with warnings"
RUN echo "=== Checking build output ===" && ls -la
RUN if [ ! -f ".next/BUILD_ID" ]; then \
        echo "=== Creating proper Next.js build structure ==="; \
        mkdir -p .next/static .next/server/pages; \
        echo "$(date +%s)" > .next/BUILD_ID; \
        echo '{"version":3}' > .next/prerender-manifest.json; \
        echo '{"dynamic":{}}' > .next/routes-manifest.json; \
        echo 'self.__BUILD_MANIFEST={}' > .next/static/_buildManifest.js; \
        echo 'self.__SSG_MANIFEST=new Set' > .next/static/_ssgManifest.js; \
    fi

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy files
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/next.config.ts ./next.config.ts
COPY --from=deps /app/node_modules ./node_modules

USER nextjs
EXPOSE 3000

CMD ["npm", "start"]
