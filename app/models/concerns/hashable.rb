# frozen_string_literal: true

module Hashable
  extend ActiveSupport::Concern

  included do
    class_attribute :hashids_encoder, default: HASHIDS_ENCODER
  end

  class_methods do
    def find_by_hashid(hashid)
      return nil if hashid.blank?

      decoded_ids = hashids_encoder.decode(hashid)
      return nil if decoded_ids.empty?

      find_by(id: decoded_ids.first)
    end

    def find_by_hashid!(hashid)
      record = find_by_hashid(hashid)
      raise ActiveRecord::RecordNotFound, t("messages.errors.not_found") unless record

      record
    end

    def find_universal(param)
      if param.match?(/^\d+$/)
        find(param)
      else
        find_by_hashid!(param)
      end
    end
  end

  def to_param
    @hashed_param ||= self.class.hashids_encoder.encode(id)
  end

  def raw_id
    id
  end

  def valid_hashid?(hashid)
    decoded = self.class.hashids_encoder.decode(hashid)
    decoded.any? && decoded.first == id
  end
end
