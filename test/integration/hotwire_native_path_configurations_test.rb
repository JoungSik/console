require "test_helper"

class HotwireNativePathConfigurationsTest < ActionDispatch::IntegrationTest
  test "인증 없이 iOS 경로 설정을 조회할 수 있다" do
    get hotwire_native_path_configuration_url(format: :json)

    assert_response :success
    assert_equal "application/json", response.media_type
    assert_includes response.headers["Cache-Control"], "public"

    path_configuration = JSON.parse(response.body)
    assert_equal({}, path_configuration.fetch("settings"))
    assert path_configuration.fetch("rules").any? { |rule| rule.dig("properties", "context") == "modal" }
  end
end
