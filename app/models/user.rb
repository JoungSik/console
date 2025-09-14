class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :collections, dependent: :destroy
  has_many :collection_links, through: :collections, source: :links

  has_many :todo_lists, dependent: :destroy

  encrypts :email_address, deterministic: true
  encrypts :name

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
end
