# Multi-stage Dockerfile for Meta-Env Project Template
# Supports both Node.js and Python applications

# ================================
# Stage 1: Base - Common Dependencies
# ================================
FROM node:20-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git \
    curl \
    bash \
    build-base \
    postgresql-client \
    redis

WORKDIR /app

# ================================
# Stage 2: Node.js Dependencies
# ================================
FROM base AS node-deps

# Copy package files
COPY package*.json ./
COPY yarn.lock* ./
COPY pnpm-lock.yaml* ./

# Install Node.js dependencies
RUN if [ -f yarn.lock ]; then \
        yarn install --frozen-lockfile; \
    elif [ -f pnpm-lock.yaml ]; then \
        npm install -g pnpm && pnpm install --frozen-lockfile; \
    else \
        npm ci; \
    fi

# ================================
# Stage 3: Python Dependencies
# ================================
FROM base AS python-deps

# Copy Python requirements
COPY requirements*.txt ./

# Install Python dependencies
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    if [ -f requirements.txt ]; then \
        python3 -m pip install --no-cache-dir -r requirements.txt; \
    fi

# ================================
# Stage 4: Development Environment
# ================================
FROM base AS development

# Copy dependencies from previous stages
COPY --from=node-deps /app/node_modules ./node_modules
COPY --from=python-deps /usr/lib/python3.* /usr/lib/python3.*

# Install development tools
RUN apk add --no-cache \
    vim \
    nano \
    htop

# Copy application code
COPY . .

# Create non-root user for development
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

# Expose common development ports
EXPOSE 3000 3001 5000 8000 8080

# Default command for development
CMD ["npm", "run", "dev"]

# ================================
# Stage 5: Builder - Compile Application
# ================================
FROM base AS builder

# Copy dependencies
COPY --from=node-deps /app/node_modules ./node_modules
COPY --from=python-deps /usr/lib/python3.* /usr/lib/python3.*

# Copy source code
COPY . .

# Build the application
RUN if [ -f "package.json" ]; then \
        npm run build 2>/dev/null || true; \
    fi

# Remove development dependencies
RUN if [ -f yarn.lock ]; then \
        yarn install --frozen-lockfile --production && \
        yarn cache clean; \
    elif [ -f pnpm-lock.yaml ]; then \
        pnpm install --frozen-lockfile --prod && \
        pnpm store prune; \
    else \
        npm ci --only=production && \
        npm cache clean --force; \
    fi

# ================================
# Stage 6: Production Environment
# ================================
FROM node:20-alpine AS production

# Install minimal runtime dependencies
RUN apk add --no-cache \
    python3 \
    postgresql-client \
    redis \
    curl \
    bash

WORKDIR /app

# Copy built application from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Copy Python dependencies if they exist
COPY --from=builder /usr/lib/python3.* /usr/lib/python3.* 2>/dev/null || true

# Copy configuration files
COPY --from=builder /app/.env.example ./.env.example
COPY --from=builder /app/configs ./configs

# Create non-root user for production
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:${PORT:-3000}/health || exit 1

# Expose application port
EXPOSE 3000

# Production command
CMD ["node", "dist/index.js"]

# ================================
# Stage 7: Testing Environment
# ================================
FROM development AS testing

# Install testing tools
RUN npm install -g jest pytest

# Copy test files
COPY tests/ ./tests/

# Run tests
CMD ["npm", "test"]

# ================================
# Stage 8: AI Development Environment
# ================================
FROM development AS ai-dev

USER root

# Install AI/ML specific dependencies
RUN apk add --no-cache \
    python3-dev \
    gcc \
    g++ \
    musl-dev \
    linux-headers

# Install AI frameworks
RUN python3 -m pip install --no-cache-dir \
    langchain \
    chromadb \
    pyautogen \
    litellm \
    chainlit \
    fastapi \
    uvicorn

# Install Ollama client
RUN curl -fsSL https://ollama.ai/install.sh | sh || true

USER appuser

# Expose additional AI service ports
EXPOSE 7860 8000 8501

CMD ["npm", "run", "dev"]

# ================================
# Stage 9: Nginx Static Server
# ================================
FROM nginx:alpine AS nginx-static

# Copy built static files
COPY --from=builder /app/dist /usr/share/nginx/html
COPY configs/nginx/nginx.conf /etc/nginx/nginx.conf

# Create custom nginx config for SPA
RUN echo 'server { \n\
    listen 80; \n\
    server_name localhost; \n\
    root /usr/share/nginx/html; \n\
    index index.html; \n\
    location / { \n\
        try_files $uri $uri/ /index.html; \n\
    } \n\
    location /health { \n\
        return 200 "OK"; \n\
        add_header Content-Type text/plain; \n\
    } \n\
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# ================================
# Build Instructions:
# ================================
# Development:
#   docker build --target development -t meta-env:dev .
#   docker run -v $(pwd):/app -p 3000:3000 meta-env:dev
#
# Production:
#   docker build --target production -t meta-env:prod .
#   docker run -p 3000:3000 meta-env:prod
#
# Testing:
#   docker build --target testing -t meta-env:test .
#   docker run meta-env:test
#
# AI Development:
#   docker build --target ai-dev -t meta-env:ai-dev .
#   docker run -v $(pwd):/app -p 8000:8000 meta-env:ai-dev
#
# Static Site:
#   docker build --target nginx-static -t meta-env:static .
#   docker run -p 80:80 meta-env:static
