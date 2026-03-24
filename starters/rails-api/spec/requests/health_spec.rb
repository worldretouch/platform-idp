# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health", type: :request do
  describe "GET /health/live" do
    it "returns ok" do
      get "/health/live"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["status"]).to eq("ok")
    end
  end

  describe "GET /health/ready" do
    it "returns ok or degraded" do
      get "/health/ready"
      expect(response.status).to be_in([200, 503])
      body = JSON.parse(response.body)
      expect(body).to have_key("status")
      expect(body).to have_key("checks")
    end
  end
end
