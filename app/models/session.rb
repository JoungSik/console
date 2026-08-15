class Session < ApplicationRecord
  belongs_to :user
  has_many :push_registrations, dependent: :destroy
end
