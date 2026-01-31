class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :collections, dependent: :destroy
  has_many :collection_links, through: :collections, source: :links

  has_many :todo_lists, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy

  # 사용자의 모든 구독으로 알림 전송
  def send_push_notification(title:, body:, url: nil)
    push_subscriptions.find_each do |subscription|
      subscription.send_notification(title: title, body: body, url: url)
    end
  end

  encrypts :email_address, deterministic: true
  encrypts :name

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
end
