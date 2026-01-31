# Web Push 구독 정보를 저장하는 모델
class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true, uniqueness: true
  validates :p256dh_key, presence: true
  validates :auth_key, presence: true

  # Push 알림 전송
  def send_notification(title:, body:, url: nil, icon: nil)
    message = {
      title: title,
      body: body,
      icon: icon || "/icon.png",
      url: url
    }.to_json

    WebPush.payload_send(
      message: message,
      endpoint: endpoint,
      p256dh: p256dh_key,
      auth: auth_key,
      vapid: vapid_credentials,
      ttl: 86400,
      urgency: "normal"
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    # 만료/유효하지 않은 구독은 삭제
    destroy
    false
  rescue WebPush::Error => e
    Rails.logger.error("Push notification failed: #{e.message}")
    false
  end

  private

  def vapid_credentials
    {
      subject: Rails.application.credentials.dig(:vapid, :subject),
      public_key: Rails.application.credentials.dig(:vapid, :public_key),
      private_key: Rails.application.credentials.dig(:vapid, :private_key)
    }
  end
end
