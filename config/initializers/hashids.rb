# frozen_string_literal: true

class HashidsConfig
  SETTINGS = {
    development: {
      salt: "dev-salt-key",
      min_length: 6,
      alphabet: "abcdefghijklmnopqrstuvwxyz0123456789"
    },
    test: {
      salt: "test-salt-for-consistent-results",
      min_length: 6,
      alphabet: "abcdefghijklmnopqrstuvwxyz0123456789"
    },
    production: {
      salt: Rails.application.credentials.hashids_salt,
      min_length: 8,
      alphabet: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }
  }.freeze

  def self.current
    SETTINGS[Rails.env.to_sym] || SETTINGS[:production]
  end
end

HASHIDS_ENCODER = Hashids.new(
  HashidsConfig.current[:salt],
  HashidsConfig.current[:min_length],
  HashidsConfig.current[:alphabet]
).freeze
