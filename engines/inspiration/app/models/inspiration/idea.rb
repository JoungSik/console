module Inspiration
  class Idea < ApplicationRecord
    MAX_TITLE_LENGTH = 200

    enum :status, { spark: 0, reviewing: 1, in_progress: 2, on_hold: 3, done: 4, dropped: 5 }, validate: true

    has_many :notes, dependent: :destroy

    validates :user_id, presence: true
    validates :title, presence: true, length: { maximum: MAX_TITLE_LENGTH }
    validates :reference_url, format: {
      with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/,
      message: :invalid_url_format
    }, allow_blank: true

    scope :by_user, ->(user_id) { where(user_id: user_id) }
    scope :recent, -> { order(updated_at: :desc, id: :desc) }

    def self.human_status(status)
      I18n.t(status, scope: [ :activerecord, :attributes, model_name.i18n_key, :statuses ])
    end

    def status_label
      self.class.human_status(status)
    end

    def reference_uri
      return if reference_url.blank?

      uri = URI.parse(reference_url)
      uri if uri.is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      nil
    end
  end
end
