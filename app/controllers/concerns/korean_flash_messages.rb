# frozen_string_literal: true

module KoreanFlashMessages
  extend ActiveSupport::Concern

  private

  # 생성 성공 메시지
  # @param resource [String] 생성된 리소스 인스턴스
  def created_flash_message(resource)
    t("messages.success.created_without_particle", resource: apply_subject_particle(resource))
  end

  # 수정 성공 메시지
  # @param resource [String] 수정된 리소스 인스턴스
  def updated_flash_message(resource)
    t("messages.success.updated_without_particle", resource: apply_subject_particle(resource))
  end

  # 삭제 성공 메시지
  # @param resource [String] 삭제될 리소스 인스턴스 (삭제 전 호출)
  def deleted_flash_message(resource)
    t("messages.success.deleted_without_particle", resource: apply_subject_particle(resource))
  end

  # 주격 조사 적용 (이/가)
  # @param word [String] 단어
  # @return [String] 조사가 적용된 단어
  def apply_subject_particle(word)
    apply_korean_particle(word, "이", "가")
  end

  # 목적격 조사 적용 (을/를)
  # @param word [String] 단어
  # @return [String] 조사가 적용된 단어
  def apply_object_particle(word)
    apply_korean_particle(word, "을", "를")
  end

  # 보조사 적용 (은/는)
  # @param word [String] 단어
  # @return [String] 조사가 적용된 단어
  def apply_topic_particle(word)
    apply_korean_particle(word, "은", "는")
  end

  # 한국어 조사 적용 핵심 로직
  # @param word [String] 단어
  # @param with_batchim [String] 받침 있을 때 조사
  # @param without_batchim [String] 받침 없을 때 조사
  # @return [String] 조사가 적용된 단어
  def apply_korean_particle(word, with_batchim, without_batchim)
    return word if word.blank?

    last_char = word.strip[-1]

    if has_batchim?(last_char)
      "#{word}#{with_batchim}"
    else
      "#{word}#{without_batchim}"
    end
  end

  # 받침 유무 판별
  # @param char [String] 판별할 한글 글자
  # @return [Boolean] 받침이 있으면 true
  def has_batchim?(char)
    return false if char.nil? || char.empty?

    code = char.ord
    return false unless (44032..55203).include?(code)

    ((code - 44032) % 28) != 0
  end
end
