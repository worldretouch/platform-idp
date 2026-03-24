# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Observability logging config", type: :request do
  it "configures request_id and trace_id log tags" do
    tags = Rails.application.config.log_tags
    expect(tags).not_to be_nil
    expect(tags).to include(:request_id)
    expect(tags.any? { |tag| tag.respond_to?(:call) }).to be(true)
  end
end
