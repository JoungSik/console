class Link < ApplicationRecord
  include Hashable

  belongs_to :user
  belongs_to :collection, optional: true, counter_cache: :links_count

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }
  validates :url, presence: true, length: { maximum: 2000 }, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: :invalid_url_format
  }

  before_validation :sanitize
  after_create :fetch_metadata_async

  private

  def sanitize
    self.url = url.strip
    self.description = description&.strip&.presence
  end

  def fetch_metadata_async
    # LinkMetadataFetchJob.perform_later(self)
  end
end
