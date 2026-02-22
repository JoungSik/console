require "test_helper"

class Console::DashboardComponentTest < ActiveSupport::TestCase
  test "initialize로 user_id를 받는다" do
    component = Console::DashboardComponent.new(user_id: 42)

    assert_equal 42, component.user_id
  end

  test "plugin_name은 NotImplementedError를 발생시킨다" do
    component = Console::DashboardComponent.new(user_id: 1)

    assert_raises(NotImplementedError) { component.plugin_name }
  end

  test "load_data는 NotImplementedError를 발생시킨다" do
    component = Console::DashboardComponent.new(user_id: 1)

    assert_raises(NotImplementedError) { component.load_data }
  end

  test "partial_path는 NotImplementedError를 발생시킨다" do
    component = Console::DashboardComponent.new(user_id: 1)

    assert_raises(NotImplementedError) { component.partial_path }
  end

  test "locals는 component를 포함한 해시를 반환한다" do
    component = Console::DashboardComponent.new(user_id: 1)

    assert_equal({ component: component }, component.locals)
  end
end
