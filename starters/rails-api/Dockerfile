# Rails API — Platform Service
# Build stage
FROM ruby:3.2-alpine AS builder
ARG GIT_SHA=unknown
ARG SERVICE_NAME=rails-api
ARG RUNTIME=rails

RUN apk add --no-cache build-base postgresql-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' \
  && bundle config set --local without 'development test' \
  && bundle install

# Runtime stage
FROM ruby:3.2-alpine
ARG GIT_SHA=unknown
ARG SERVICE_NAME=rails-api
ARG RUNTIME=rails

LABEL org.opencontainers.image.revision="${GIT_SHA}"
LABEL platform.service="${SERVICE_NAME}"
LABEL platform.runtime="${RUNTIME}"

RUN apk add --no-cache libpq && adduser -D app

USER app
WORKDIR /app

COPY --from=builder /app /app
COPY . .

ENV RAILS_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
