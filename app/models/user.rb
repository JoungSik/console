class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :push_subscriptions, dependent: :destroy

  # 사용자의 모든 구독으로 알림 전송 (하나라도 성공하면 true 반환)
  def send_push_notification(title:, body:, url: nil)
    sent_at_least_once = false
    push_subscriptions.find_each do |subscription|
      sent_at_least_once ||= subscription.send_notification(title: title, body: body, url: url)
    end
    sent_at_least_once
  end

  encrypts :email_address, deterministic: true
  encrypts :name

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
end
