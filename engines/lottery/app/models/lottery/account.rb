module Lottery
  class Account < ApplicationRecord
    encrypts :login_id
    encrypts :password

    has_many :purchase_records, dependent: :delete_all
    has_many :purchase_requests, dependent: :delete_all

    validates :user_id, presence: true, uniqueness: true
    validates :login_id, :password, presence: true

    scope :by_user, ->(user_id) { where(user_id: user_id) }

    def synced?
      synced_at.present?
    end
  end
end
