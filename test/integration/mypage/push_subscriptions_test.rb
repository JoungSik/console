require "test_helper"

class Mypage::PushSubscriptionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @subscription_params = {
      push_subscription: {
        endpoint: "https://push.example.com/test-endpoint",
        p256dh_key: "test-p256dh-key",
        auth_key: "test-auth-key"
      }
    }
  end

  test "푸시 구독을 생성할 수 있다" do
    assert_difference "PushSubscription.count", 1 do
      post mypage_push_subscriptions_url, params: @subscription_params, as: :json
    end
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "subscribed", json["status"]
  end

  test "동일 endpoint로 중복 구독 시 기존을 업데이트한다" do
    post mypage_push_subscriptions_url, params: @subscription_params, as: :json
    assert_response :created

    assert_no_difference "PushSubscription.count" do
      post mypage_push_subscriptions_url, params: @subscription_params, as: :json
    end
  end

  test "푸시 구독을 삭제할 수 있다" do
    post mypage_push_subscriptions_url, params: @subscription_params, as: :json
    subscription_id = JSON.parse(response.body)["id"]

    assert_difference "PushSubscription.count", -1 do
      delete mypage_push_subscription_url(subscription_id), as: :json
    end
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "unsubscribed", json["status"]
  end

  test "존재하지 않는 구독을 삭제하면 404를 반환한다" do
    delete mypage_push_subscription_url(999999), as: :json
    assert_response :not_found
  end
end
