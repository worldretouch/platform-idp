# Node.js API — Platform Service
# Build stage
FROM node:20-alpine3.20 AS builder
ARG GIT_SHA=unknown
ARG SERVICE_NAME=node-api
ARG RUNTIME=node

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage
FROM node:20-alpine3.20
ARG GIT_SHA=unknown
ARG SERVICE_NAME=node-api
ARG RUNTIME=node

LABEL org.opencontainers.image.revision="${GIT_SHA}"
LABEL platform.service="${SERVICE_NAME}"
LABEL platform.runtime="${RUNTIME}"

RUN apk upgrade --no-cache && adduser -D app
USER app
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts
COPY --from=builder /app/dist ./dist

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

CMD ["node", "dist/index.js"]
