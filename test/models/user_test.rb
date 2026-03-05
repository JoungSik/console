require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
  end

  test "plugin_enabled?는 레코드가 없으면 true를 반환한다" do
    assert @user.plugin_enabled?(:bookmarks)
  end

  test "plugin_enabled?는 비활성화된 플러그인에 false를 반환한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    assert_not @user.plugin_enabled?(:todos)
  end

  test "plugin_enabled?는 심볼과 문자열 모두 지원한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    assert_not @user.plugin_enabled?("todos")
    assert_not @user.plugin_enabled?(:todos)
  end

  test "enabled_plugins는 비활성 플러그인을 제외한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    enabled = @user.enabled_plugins
    enabled_names = enabled.map(&:name)

    assert_not_includes enabled_names, :todos
    assert_includes enabled_names, :bookmarks
  end

  test "approaching_deletion_plugins는 삭제 임박 플러그인을 반환한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: 25.days.ago)

    approaching = @user.approaching_deletion_plugins
    assert approaching.any? { |item| item[:plugin].name == :todos }
  end

  test "needs_terms_acceptance?는 동의가 없으면 true를 반환한다" do
    assert @user.needs_terms_acceptance?
  end

  test "needs_terms_acceptance?는 모두 동의 시 false를 반환한다" do
    terms = LegalDocument.latest_terms
    privacy = LegalDocument.latest_privacy_policy

    @user.legal_agreements.create!(legal_document: terms, accepted_at: Time.current)
    @user.legal_agreements.create!(legal_document: privacy, accepted_at: Time.current)

    assert_not @user.needs_terms_acceptance?
  end

  test "needs_terms_acceptance?는 약관 버전 변경 시 true를 반환한다" do
    # 이전 버전에만 동의
    old_terms = legal_documents(:terms_v1)
    privacy = LegalDocument.latest_privacy_policy

    @user.legal_agreements.create!(legal_document: old_terms, accepted_at: Time.current)
    @user.legal_agreements.create!(legal_document: privacy, accepted_at: Time.current)

    # 최신 버전(terms_v2)에 동의하지 않았으므로 true
    assert @user.needs_terms_acceptance?
  end
end
