require "test_helper"

class PwaManifestTest < ActionDispatch::IntegrationTest
  test "현재 웹 앱 버전을 제공한다" do
    get pwa_manifest_url(format: :json)

    assert_response :success
    assert_equal "1.0.0", response.parsed_body["version"]
  end
end
