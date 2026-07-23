require "test_helper"

class NavigationHelperTest < ActiveSupport::TestCase
  include NavigationHelper

  attr_accessor :authenticated_flag, :stub_user, :stub_path

  setup do
    @authenticated_flag = false
    @stub_user = nil
    @stub_path = "/"
  end

  test "비인증 상태에서는 홈과 로그인 항목만 구성한다" do
    self.authenticated_flag = false

    items = navigation_items

    assert_equal 2, items.size
    assert_equal main_app.root_path, items.first[:path]
    assert_equal main_app.new_session_path, items.last[:path]
  end

  test "인증 상태에서는 홈으로 시작하고 마이페이지로 끝난다" do
    self.authenticated_flag = true
    self.stub_user = user_double([])

    items = navigation_items

    assert_equal main_app.root_path, items.first[:path]
    assert_equal main_app.mypage_user_path, items.last[:path]
    assert_not_includes items.map { |item| item[:path] }, main_app.new_session_path
  end

  test "인증 상태에서 활성 플러그인이 홈과 마이페이지 사이에 추가된다" do
    self.authenticated_flag = true
    plugin = Struct.new(:label, :path, :icon).new("할 일", "/todos", "check")
    self.stub_user = user_double([ plugin ])

    paths = navigation_items.map { |item| item[:path] }

    assert_equal [ main_app.root_path, "/todos", main_app.mypage_user_path ], paths
  end

  test "루트 경로 항목은 현재 경로가 정확히 일치할 때만 활성이다" do
    home = navigation_items.first

    self.stub_path = "/"
    assert navigation_item_active?(home)

    self.stub_path = "/todos"
    assert_not navigation_item_active?(home)
  end

  test "일반 항목은 현재 경로가 active_paths로 시작하면 활성이다" do
    item = { path: "/mypage/user", active_paths: [ "/mypage/user" ] }

    self.stub_path = "/mypage/user/edit"
    assert navigation_item_active?(item)

    self.stub_path = "/todos"
    assert_not navigation_item_active?(item)
  end

  private

  def authenticated?
    authenticated_flag
  end

  def current_user
    stub_user
  end

  def request
    Struct.new(:path).new(stub_path)
  end

  def main_app
    @main_app ||= Class.new do
      include Rails.application.routes.url_helpers

      def default_url_options
        {}
      end
    end.new
  end

  def t(key)
    key
  end

  def user_double(plugins)
    Struct.new(:enabled_plugins).new(plugins)
  end
end
