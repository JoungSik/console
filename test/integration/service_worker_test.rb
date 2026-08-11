require "test_helper"

class ServiceWorkerTest < ActionDispatch::IntegrationTest
  test "FCM 알림 클릭을 처리하는 루트 Service Worker를 제공한다" do
    get service_worker_url(format: :js)

    assert_response :success
    assert_equal "application/javascript", response.media_type
    assert_equal "/", response.headers["Service-Worker-Allowed"]
    assert_includes response.body, 'self.addEventListener("notificationclick"'
    assert_not_includes response.body, "pushManager.subscribe"
  end
end
