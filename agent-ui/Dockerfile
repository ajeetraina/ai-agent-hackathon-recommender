FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json package-lock.json* ./
RUN npm install --production --frozen-lockfile || npm install --production

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
ENV NEXT_TELEMETRY_DISABLED 1

# Install dev dependencies for build
RUN npm install

# Debug: List contents before build
RUN ls -la
RUN ls -la src/

# Build the application with verbose output
RUN npm run build && ls -la .next/

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy package.json first
COPY --from=builder /app/package.json ./package.json

# Copy next config if it exists
COPY --from=builder /app/next.config.* ./ 2>/dev/null || true

# Copy public directory if it exists
COPY --from=builder /app/public ./public 2>/dev/null || mkdir -p ./public

# Copy the .next folder from the builder stage
COPY --from=builder /app/.next ./.next

# Copy production node_modules
COPY --from=deps /app/node_modules ./node_modules

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["npm", "start"]
