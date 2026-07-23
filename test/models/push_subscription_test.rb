require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @subscription = PushSubscription.create!(
      user: @user,
      endpoint: "https://push.example.com/abc",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
  end

  test "endpoint가 없으면 유효하지 않다" do
    subscription = PushSubscription.new(user: @user, p256dh_key: "k", auth_key: "a")
    assert_not subscription.valid?
  end

  test "endpoint는 유일해야 한다" do
    duplicate = PushSubscription.new(
      user: @user,
      endpoint: @subscription.endpoint,
      p256dh_key: "other-key",
      auth_key: "other-auth"
    )
    assert_not duplicate.valid?
  end

  test "p256dh_key가 없으면 유효하지 않다" do
    subscription = PushSubscription.new(user: @user, endpoint: "https://push.example.com/x", auth_key: "a")
    assert_not subscription.valid?
  end

  test "auth_key가 없으면 유효하지 않다" do
    subscription = PushSubscription.new(user: @user, endpoint: "https://push.example.com/x", p256dh_key: "k")
    assert_not subscription.valid?
  end

  test "user가 없으면 유효하지 않다" do
    subscription = PushSubscription.new(endpoint: "https://push.example.com/x", p256dh_key: "k", auth_key: "a")
    assert_not subscription.valid?
  end

  test "send_notification 성공 시 레코드를 유지하고 결과를 반환한다" do
    stub_web_push(result: true) do
      assert_no_difference "PushSubscription.count" do
        assert @subscription.send_notification(title: "제목", body: "내용")
      end
    end
  end

  test "만료된 구독은 삭제하고 false를 반환한다" do
    stub_web_push(error: WebPush::ExpiredSubscription.new(response_double, "example.com")) do
      assert_difference "PushSubscription.count", -1 do
        assert_not @subscription.send_notification(title: "제목", body: "내용")
      end
    end
  end

  test "무효한 구독은 삭제하고 false를 반환한다" do
    stub_web_push(error: WebPush::InvalidSubscription.new(response_double, "example.com")) do
      assert_difference "PushSubscription.count", -1 do
        assert_not @subscription.send_notification(title: "제목", body: "내용")
      end
    end
  end

  test "기타 WebPush 오류는 레코드를 유지하고 false를 반환한다" do
    stub_web_push(error: WebPush::PushServiceError.new(response_double, "example.com")) do
      assert_no_difference "PushSubscription.count" do
        assert_not @subscription.send_notification(title: "제목", body: "내용")
      end
    end
  end

  private

  def response_double
    Struct.new(:body).new("error body")
  end

  def stub_web_push(result: nil, error: nil)
    original = WebPush.method(:payload_send)
    WebPush.define_singleton_method(:payload_send) do |**|
      raise error if error
      result
    end
    yield
  ensure
    WebPush.define_singleton_method(:payload_send, original)
  end
end
