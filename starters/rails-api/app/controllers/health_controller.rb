# frozen_string_literal: true

class HealthController < ApplicationController
  # Platform contract: GET /health/live — liveness
  def live
    render json: { status: "ok", timestamp: Time.current.iso8601 }
  end

  # Platform contract: GET /health/ready — readiness (checks DB, Redis)
  def ready
    checks = {}
    checks["database"] = check_database if database_configured?
    checks["redis"] = check_redis if redis_configured?

    all_ok = checks.values.all? { |v| v == "ok" }
    status = all_ok ? :ok : :service_unavailable
    render json: { status: all_ok ? "ok" : "degraded", checks: checks }, status: status
  end

  private

  def database_configured?
    ENV["DATABASE_URL"].present?
  end

  def redis_configured?
    ENV["REDIS_URL"].present?
  end

  def check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    "ok"
  rescue StandardError
    "error"
  end

  def check_redis
    require "redis"
    Redis.new(url: ENV["REDIS_URL"]).ping
    "ok"
  rescue StandardError
    "error"
  end
end
