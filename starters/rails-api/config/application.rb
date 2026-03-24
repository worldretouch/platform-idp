# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "active_job/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module PlatformApi
  class Application < Rails::Application
    config.load_defaults 7.2
    config.api_only = true
    config.log_level = ENV.fetch("LOG_LEVEL", "info").downcase.to_sym
    config.log_tags = [
      :request_id,
      lambda { |req| req.headers["X-Trace-Id"] || req.request_id }
    ]
  end
end
