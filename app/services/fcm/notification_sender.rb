require "net/http"
require "openssl"
require "timeout"
require "uri"

class Fcm::NotificationSender
  SEND_ENDPOINT = "https://fcm.googleapis.com/v1/projects/%{project_id}/messages:send"
  MESSAGE_TTL = 1.day.to_i
  INVALID_REGISTRATION_CODE = "UNREGISTERED"

  def initialize(registration, access_token_provider: Fcm::AccessTokenProvider, http_client: Fcm::HttpClient,
    project_id: nil, web_push_base_url: Rails.application.config.x.web_push_base_url)
    @registration = registration
    @access_token_provider = access_token_provider
    @http_client = http_client
    @configured_project_id = project_id
    @web_push_base_url = web_push_base_url
  end

  def call(title:, body:, url: nil, icon: nil)
    response = http_client.post(
      endpoint,
      JSON.generate(message: message(title:, body:, url:, icon:)),
      request_headers
    )

    return true if response.code.to_i.between?(200, 299)

    handle_error(response)
  rescue JSON::ParserError => error
    raise Fcm::Error, "FCM 응답을 해석할 수 없습니다: #{error.message}"
  rescue Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => error
    raise Fcm::Error, "FCM 네트워크 요청 실패: #{error.message}"
  end

  private

  attr_reader :registration, :access_token_provider, :http_client, :configured_project_id, :web_push_base_url

  def endpoint
    URI(format(SEND_ENDPOINT, project_id: project_id))
  end

  def project_id
    configured_project_id.presence || Fcm::Configuration.project_id.presence ||
      raise(Fcm::ConfigurationError, "firebase.project_id credentials가 필요합니다.")
  end

  def request_headers
    {
      "Authorization" => "Bearer #{access_token_provider.call}",
      "Content-Type" => "application/json"
    }
  end

  def message(title:, body:, url:, icon:)
    destination_url = url.presence || "/"
    notification_icon = icon.presence || "/icon.png"

    {
      fid: registration.firebase_installation_id,
      notification: { title:, body: },
      data: { url: destination_url },
      android: {
        ttl: "#{MESSAGE_TTL}s",
        notification: { sound: "default" }
      },
      apns: {
        headers: { "apns-expiration" => MESSAGE_TTL.seconds.from_now.to_i.to_s },
        payload: { aps: { sound: "default" } }
      },
      webpush: {
        headers: { "TTL" => MESSAGE_TTL.to_s },
        notification: { icon: notification_icon, badge: "/icon.png" },
        fcm_options: { link: absolute_url(destination_url) }
      }
    }
  end

  def absolute_url(path)
    URI.join("#{web_push_base_url}/", path.delete_prefix("/")).to_s
  end

  def handle_error(response)
    error_payload = JSON.parse(response.body).fetch("error", {})
    error_code = error_payload.fetch("details", []).filter_map { |detail| detail["errorCode"] }.first
    message = error_payload["message"].presence || "HTTP #{response.code}"

    raise Fcm::InvalidRegistrationError, message if error_code == INVALID_REGISTRATION_CODE

    raise Fcm::Error, "FCM 요청 실패(#{error_payload["status"] || response.code}): #{message}"
  end
end
