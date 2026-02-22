require "test_helper"

class PluginRegistryTest < ActiveSupport::TestCase
  setup do
    @original_plugins = PluginRegistry.all.dup
    PluginRegistry.clear!
  end

  teardown do
    PluginRegistry.clear!
    @original_plugins.each do |p|
      PluginRegistry.register(
        name: p.name, label: p.label, icon: p.icon,
        path: p.path, position: p.position, dashboard_component: p.dashboard_component
      )
    end
  end

  test "dashboard_component 없이 등록하면 nil이 기본값" do
    PluginRegistry.register(name: :test, label: "테스트", icon: "box", path: "/test")
    plugin = PluginRegistry.find(:test)

    assert_nil plugin.dashboard_component
  end

  test "dashboard_component와 함께 등록된다" do
    PluginRegistry.register(
      name: :test, label: "테스트", icon: "box", path: "/test",
      dashboard_component: "Test::DashboardComponent"
    )
    plugin = PluginRegistry.find(:test)

    assert_equal "Test::DashboardComponent", plugin.dashboard_component
  end

  test "dashboard_plugins는 dashboard_component가 있는 플러그인만 반환한다" do
    PluginRegistry.register(name: :with_dash, label: "위젯있음", icon: "a", path: "/a", dashboard_component: "A::DC")
    PluginRegistry.register(name: :without_dash, label: "위젯없음", icon: "b", path: "/b")
    PluginRegistry.register(name: :with_dash2, label: "위젯있음2", icon: "c", path: "/c", dashboard_component: "C::DC")

    result = PluginRegistry.dashboard_plugins

    assert_equal 2, result.size
    assert_equal [:with_dash, :with_dash2], result.map(&:name)
  end

  test "dashboard_plugins는 position 순서로 정렬된다" do
    PluginRegistry.register(name: :second, label: "두번째", icon: "b", path: "/b", position: 20, dashboard_component: "B::DC")
    PluginRegistry.register(name: :first, label: "첫번째", icon: "a", path: "/a", position: 10, dashboard_component: "A::DC")

    result = PluginRegistry.dashboard_plugins

    assert_equal [:first, :second], result.map(&:name)
  end

  test "dashboard_plugins는 등록된 것이 없으면 빈 배열을 반환한다" do
    assert_equal [], PluginRegistry.dashboard_plugins
  end
end
