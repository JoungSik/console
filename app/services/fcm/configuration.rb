module Fcm::Configuration
  WEB_KEYS = %i[api_key auth_domain storage_bucket messaging_sender_id app_id measurement_id
    vapid_public_key].freeze
  REQUIRED_WEB_KEYS = %i[api_key messaging_sender_id app_id vapid_public_key].freeze
  SERVICE_ACCOUNT_KEYS = %i[client_email private_key].freeze

  module_function

  def web
    credentials = Rails.application.credentials.dig(:firebase, :web)
    return {} unless credentials

    credentials.to_h.symbolize_keys.slice(*WEB_KEYS)
  end

  def service_account
    credentials = Rails.application.credentials.dig(:firebase, :service_account)
    credentials ? credentials.to_h.deep_symbolize_keys.slice(*SERVICE_ACCOUNT_KEYS) : {}
  end

  def web_configured?
    project_id.present? && REQUIRED_WEB_KEYS.all? { |key| web[key].present? }
  end

  def firebase_web_app
    web.except(:vapid_public_key).merge(project_id: project_id).transform_keys do |key|
      key.to_s.camelize(:lower)
    end
  end

  def project_id
    Rails.application.credentials.dig(:firebase, :project_id)
  end
end
