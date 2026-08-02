require "test_helper"

class LayoutHelperTest < ActionView::TestCase
  include LayoutHelper

  attr_accessor :native_app

  test "웹 main 여백을 반환한다" do
    self.native_app = false

    assert_equal "p-8 text-gray-900", layout_main_classes("text-gray-900")
  end

  test "Native main 여백을 반환한다" do
    self.native_app = true

    assert_equal "px-4 pb-4 sm:px-6 sm:pb-6 text-gray-900", layout_main_classes("text-gray-900")
  end

  private

  def hotwire_native_app?
    native_app
  end
end
