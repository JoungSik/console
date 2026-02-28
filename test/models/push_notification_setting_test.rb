require "test_helper"

class PushNotificationSettingTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
  end

  test "유효한 설정을 생성할 수 있다" do
    setting = PushNotificationSetting.new(user: @user, plugin_name: "todos", item_key: "due_date_reminder")
    assert setting.valid?
  end

  test "plugin_name은 필수이다" do
    setting = PushNotificationSetting.new(user: @user, plugin_name: nil, item_key: "due_date_reminder")
    assert_not setting.valid?
    assert setting.errors[:plugin_name].any?
  end

  test "item_key는 필수이다" do
    setting = PushNotificationSetting.new(user: @user, plugin_name: "todos", item_key: nil)
    assert_not setting.valid?
    assert setting.errors[:item_key].any?
  end

  test "동일 사용자, 플러그인, 항목의 중복은 허용되지 않는다" do
    PushNotificationSetting.create!(user: @user, plugin_name: "todos", item_key: "due_date_reminder")

    duplicate = PushNotificationSetting.new(user: @user, plugin_name: "todos", item_key: "due_date_reminder")
    assert_not duplicate.valid?
    assert duplicate.errors[:item_key].any?
  end

  test "다른 사용자는 같은 플러그인/항목 설정을 가질 수 있다" do
    PushNotificationSetting.create!(user: @user, plugin_name: "todos", item_key: "due_date_reminder")

    other_user = users(:other_user)
    setting = PushNotificationSetting.new(user: other_user, plugin_name: "todos", item_key: "due_date_reminder")
    assert setting.valid?
  end

  test "enabled 기본값은 true이다" do
    setting = PushNotificationSetting.create!(user: @user, plugin_name: "todos", item_key: "due_date_reminder")
    assert setting.enabled?
  end

  test "for_plugin 스코프가 동작한다" do
    PushNotificationSetting.create!(user: @user, plugin_name: "todos", item_key: "due_date_reminder")
    PushNotificationSetting.create!(user: @user, plugin_name: "other", item_key: "some_key")

    assert_equal 1, PushNotificationSetting.for_plugin("todos").count
  end

  test "disabled 스코프가 동작한다" do
    PushNotificationSetting.create!(user: @user, plugin_name: "todos", item_key: "due_date_reminder", enabled: false)
    PushNotificationSetting.create!(user: @user, plugin_name: "todos", item_key: "other_key", enabled: true)

    assert_equal 1, PushNotificationSetting.disabled.count
  end
end
