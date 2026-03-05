class LegalDocument < ApplicationRecord
  enum :document_type, { terms: 0, privacy_policy: 1 }

  has_many :legal_agreements, dependent: :restrict_with_error

  validates :document_type, presence: true
  validates :version, presence: true, uniqueness: { scope: :document_type }
  validates :title, presence: true
  validates :content, presence: true
  validates :published_at, presence: true

  # 타입별 최신 게시 문서
  def self.latest_terms
    terms.where(published_at: ..Time.current).order(published_at: :desc).first
  end

  def self.latest_privacy_policy
    privacy_policy.where(published_at: ..Time.current).order(published_at: :desc).first
  end
end
