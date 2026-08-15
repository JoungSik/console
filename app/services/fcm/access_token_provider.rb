require "googleauth"
require "stringio"

module Fcm::AccessTokenProvider
  SCOPE = "https://www.googleapis.com/auth/firebase.messaging"

  module_function

  def call
    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(service_account_credentials.to_json),
      scope: SCOPE
    )

    credentials.fetch_access_token!.fetch("access_token")
  rescue Fcm::ConfigurationError
    raise
  rescue StandardError => error
    raise Fcm::ConfigurationError, "Firebase access token 발급 실패: #{error.message}"
  end

  def service_account_credentials
    project_id = Fcm::Configuration.project_id.presence ||
      raise(Fcm::ConfigurationError, "firebase.project_id credentials가 필요합니다.")
    service_account = Fcm::Configuration.service_account.presence ||
      raise(Fcm::ConfigurationError, "firebase.service_account credentials가 필요합니다.")

    { type: "service_account", project_id: project_id }.merge(service_account)
  end

  private_class_method :service_account_credentials
end
