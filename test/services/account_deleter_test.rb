require "test_helper"

class AccountDeleterTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @other_user = users(:other_user)
  end

  test "계정과 모든 코어 및 플러그인 데이터를 삭제한다" do
    create_account_data_for(@user)
    create_plugin_data_for(@user)

    assert AccountDeleter.new(@user).call

    assert_not User.exists?(@user.id)
    assert_equal 0, Session.where(user_id: @user.id).count
    assert_equal 0, PushRegistration.where(user_id: @user.id).count
    assert_equal 0, PushNotificationSetting.where(user_id: @user.id).count
    assert_equal 0, PushNotificationLog.where(user_id: @user.id).count
    assert_equal 0, UserPlugin.where(user_id: @user.id).count
    assert_equal 0, Journal::Post.where(user_id: @user.id).count
    assert_equal 0, Todo::List.where(user_id: @user.id).count
  end

  test "활성화 상태와 관계없이 플러그인 데이터를 삭제한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: true)
    UserPlugin.create!(user: @user, plugin_name: "posts", enabled: false, disabled_at: Time.current)
    create_plugin_data_for(@user)

    assert AccountDeleter.new(@user).call

    assert_equal 0, Journal::Post.where(user_id: @user.id).count
    assert_equal 0, Todo::List.where(user_id: @user.id).count
  end

  test "다른 사용자의 데이터는 삭제하지 않는다" do
    create_account_data_for(@user)
    create_plugin_data_for(@user)
    create_account_data_for(@other_user, installation_suffix: "other")
    create_plugin_data_for(@other_user)

    assert AccountDeleter.new(@user).call

    assert User.exists?(@other_user.id)
    assert Session.exists?(user_id: @other_user.id)
    assert PushRegistration.exists?(user_id: @other_user.id)
    assert PushNotificationSetting.exists?(user_id: @other_user.id)
    assert PushNotificationLog.exists?(user_id: @other_user.id)
    assert UserPlugin.exists?(user_id: @other_user.id)
    assert Journal::Post.exists?(user_id: @other_user.id)
    assert Todo::List.exists?(user_id: @other_user.id)
  end

  test "클리너가 false를 반환하면 앞서 삭제한 플러그인 데이터를 원복한다" do
    list = Todo::List.create!(title: "원복할 목록", user_id: @user.id)
    post = Journal::Post.create!(body: "유지할 포스트", user_id: @user.id)
    data_cleaner = failing_data_cleaner(failure: :false)

    assert_not AccountDeleter.new(@user, data_cleaner: data_cleaner).call

    assert User.exists?(@user.id)
    assert Todo::List.exists?(list.id)
    assert Journal::Post.exists?(post.id)
  end

  test "클리너에서 예외가 발생하면 앞서 삭제한 플러그인 데이터를 원복한다" do
    list = Todo::List.create!(title: "원복할 목록", user_id: @user.id)
    post = Journal::Post.create!(body: "유지할 포스트", user_id: @user.id)
    data_cleaner = failing_data_cleaner(failure: :exception)

    assert_not AccountDeleter.new(@user, data_cleaner: data_cleaner).call

    assert User.exists?(@user.id)
    assert Todo::List.exists?(list.id)
    assert Journal::Post.exists?(post.id)
  end

  test "클리너가 누락되면 계정을 삭제하지 않는다" do
    missing_plugin = Struct.new(:name).new(:missing)
    log_collector = Struct.new(:message) do
      def error(message)
        self.message = message
      end
    end.new

    assert_not AccountDeleter.new(@user, plugins: [ missing_plugin ], logger: log_collector).call

    assert User.exists?(@user.id)
    assert_includes log_collector.message, "AccountDeleter::TransactionUnsupportedError"
  end

  test "코어 계정 삭제가 실패하면 플러그인 데이터를 원복한다" do
    list = Todo::List.create!(title: "원복할 목록", user_id: @user.id)
    post = Journal::Post.create!(body: "원복할 포스트", user_id: @user.id)
    user_id = @user.id
    account = Object.new
    account.define_singleton_method(:id) { user_id }
    account.define_singleton_method(:destroy!) { raise StandardError }

    assert_not AccountDeleter.new(account).call

    assert User.exists?(@user.id)
    assert Todo::List.exists?(list.id)
    assert Journal::Post.exists?(post.id)
  end

  private

  def create_account_data_for(user, installation_suffix: user.id)
    first_session = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    second_session = user.sessions.create!(user_agent: "test-2", ip_address: "127.0.0.2")
    PushRegistration.create!(
      user: user,
      session: first_session,
      firebase_installation_id: "installation-#{installation_suffix}-1",
      platform: "web",
      last_registered_at: Time.current
    )
    PushRegistration.create!(
      user: user,
      session: second_session,
      firebase_installation_id: "installation-#{installation_suffix}-2",
      platform: "ios",
      last_registered_at: Time.current
    )
    PushNotificationSetting.create!(user: user, plugin_name: "todos", item_key: "due_date_reminder")
    PushNotificationLog.create!(
      user: user,
      title: "알림",
      body: "본문",
      requested_at: Time.current
    )
    UserPlugin.create!(user: user, plugin_name: "todos")
  end

  def create_plugin_data_for(user)
    Journal::Post.create!(body: "삭제 대상 포스트", user_id: user.id)
    Todo::List.create!(title: "삭제 대상 목록", user_id: user.id).items.create!(title: "삭제 대상 할 일")
  end

  def failing_data_cleaner(failure:)
    Object.new.tap do |cleaner|
      cleaner.define_singleton_method(:transaction_supported?) do |plugin_name:|
        Console::PluginDataCleaner.transaction_supported?(plugin_name: plugin_name)
      end
      cleaner.define_singleton_method(:with_transaction) do |plugin_name:, &block|
        Console::PluginDataCleaner.with_transaction(plugin_name: plugin_name, &block)
      end
      cleaner.define_singleton_method(:clean_data_for) do |plugin_name:, user_id:|
        if plugin_name.to_sym == :posts
          raise StandardError if failure == :exception

          false
        else
          Console::PluginDataCleaner.clean_data_for(plugin_name: plugin_name, user_id: user_id)
        end
      end
    end
  end
end
