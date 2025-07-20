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

# Try building and show all output - even errors
RUN echo "=== Starting Next.js build ===" && \
    npm run build && \
    echo "=== Build completed successfully ===" && \
    ls -la .next/ && \
    echo "=== .next contents ===" && \
    find .next -type f | head -20

# If build fails, create a dummy .next directory so we can see what happened
RUN if [ ! -d ".next" ]; then \
        echo "=== Build failed - creating dummy .next ===" && \
        mkdir -p .next && \
        echo "Build failed" > .next/build-failed.txt; \
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

# Copy .next directory (even if it's a dummy one)
COPY --from=builder /app/.next ./.next

# Copy node_modules
COPY --from=deps /app/node_modules ./node_modules

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["npm", "start"]
