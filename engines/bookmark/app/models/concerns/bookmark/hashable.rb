module Bookmark
  # URL에 숫자 ID 대신 해시 ID를 사용하기 위한 concern
  module Hashable
    extend ActiveSupport::Concern

    class_methods do
      def find_by_hashid(hashid)
        return nil if hashid.blank?

        decoded_ids = Bookmark.hashids_encoder.decode(hashid)
        return nil if decoded_ids.empty?

        find_by(id: decoded_ids.first)
      end

      def find_by_hashid!(hashid)
        find_by_hashid(hashid) || raise(ActiveRecord::RecordNotFound)
      end

      # 숫자 ID와 해시 ID 모두 지원
      def find_universal(param)
        if param.to_s.match?(/\A\d+\z/)
          find(param)
        else
          find_by_hashid!(param)
        end
      end
    end

    def to_param
      @hashed_param ||= Bookmark.hashids_encoder.encode(id)
    end
  end
end
