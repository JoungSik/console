require "test_helper"

class Fcm::NotificationSenderTest < ActiveSupport::TestCase
  Response = Data.define(:code, :body)

  setup do
    user = users(:test_user)
    session = user.sessions.create!
    @registration = PushRegistration.new(
      user: user,
      session: session,
      firebase_installation_id: "test-installation-id",
      platform: "web",
      last_registered_at: Time.current
    )
    @access_token_provider = -> { "test-access-token" }
  end

  test "FID를 대상으로 Android, iOS, Web 공통 메시지를 발송한다" do
    http_client = fake_http_client(Response.new(code: "200", body: '{"name":"message-id"}'))
    sender = build_sender(http_client)

    assert sender.call(title: "제목", body: "내용", url: "/todos")

    request = JSON.parse(http_client.body)
    message = request.fetch("message")
    assert_equal "test-installation-id", message["fid"]
    assert_equal({ "title" => "제목", "body" => "내용" }, message["notification"])
    assert_equal "/todos", message.dig("data", "url")
    assert_equal "https://example.com/todos", message.dig("webpush", "fcm_options", "link")
    assert_equal "Bearer test-access-token", http_client.headers["Authorization"]
  end

  test "UNREGISTERED 응답은 무효 등록 오류를 발생시킨다" do
    response = Response.new(
      code: "404",
      body: { error: { status: "NOT_FOUND", message: "not registered", details: [ { errorCode: "UNREGISTERED" } ] } }.to_json
    )

    assert_raises Fcm::InvalidRegistrationError do
      build_sender(fake_http_client(response)).call(title: "제목", body: "내용")
    end
  end

  test "일시적인 FCM 오류는 일반 발송 오류를 발생시킨다" do
    response = Response.new(
      code: "503",
      body: { error: { status: "UNAVAILABLE", message: "retry later" } }.to_json
    )

    error = assert_raises Fcm::Error do
      build_sender(fake_http_client(response)).call(title: "제목", body: "내용")
    end
    assert_includes error.message, "UNAVAILABLE"
  end

  test "네트워크 오류는 일반 발송 오류로 변환한다" do
    http_client = Object.new
    http_client.define_singleton_method(:post) { |*| raise Timeout::Error, "execution expired" }

    error = assert_raises Fcm::Error do
      build_sender(http_client).call(title: "제목", body: "내용")
    end
    assert_includes error.message, "네트워크 요청 실패"
  end

  private

  def build_sender(http_client)
    Fcm::NotificationSender.new(
      @registration,
      access_token_provider: @access_token_provider,
      http_client: http_client,
      project_id: "test-project",
      web_push_base_url: "https://example.com"
    )
  end

  def fake_http_client(response)
    Class.new do
      class << self
        attr_accessor :body, :headers
      end

      define_singleton_method(:post) do |_endpoint, body, headers|
        self.body = body
        self.headers = headers
        response
      end
    end
  end
end
