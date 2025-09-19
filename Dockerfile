# ---- Build stage ----
FROM node:16.17.0-alpine AS builder

WORKDIR /app

# Copy dependency files first (better caching)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# Copy the rest of the source code
COPY . .

# Pass API key into Next.js (must use NEXT_PUBLIC_ prefix for frontend)
ARG TMDB_V3_API_KEY
ENV NEXT_PUBLIC_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}

# Build Next.js app
RUN yarn build


# ---- Runtime stage ----
FROM node:16.17.0-alpine

WORKDIR /app

# Copy only needed files from builder
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# Expose Next.js default port
EXPOSE 3000

# Start the app
CMD ["yarn", "start"]
