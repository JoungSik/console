require "test_helper"

class Mypage::UsersTest < ActionDispatch::IntegrationTest
  NATIVE_HEADERS = { "User-Agent" => "Console Hotwire Native iOS" }.freeze

  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  test "마이페이지를 조회할 수 있다" do
    get mypage_user_url
    assert_response :success
    assert_select "html.theme-system[data-controller~='theme'][data-controller~='bridge--theme'][data-theme-preference-value='system']"
    assert_select "html[data-action~='theme:sync->bridge--theme#sync']"
    assert_select "body[data-theme-preference='system']"
    assert_select "input[name='theme[value]']", count: 3
    assert_select "form[data-action~='turbo:submit-end->theme#submitEnd']"
    assert_select "a[href='#{mypage_plugins_path}']", count: 1
    assert_select "a[href='#{mypage_push_notifications_path}']", count: 1
    assert_select "form#account_deletion_form[action='#{mypage_user_path}'][data-turbo-confirm]"
    assert_select "form#account_deletion_form input[name='_method'][value='delete']"
    assert_select "form#account_deletion_form[data-controller~='bridge--form']", count: 0
    assert_select "form#account_deletion_form [data-bridge--form-target]", count: 0
    assert_select "form[data-controller~='bridge--form'] input[name='_method'][value='patch']", count: 1
    assert_select "#account_deletion_current_password[value]", count: 0
  end

  test "Native 마이페이지에는 중복 설정 링크만 표시되지 않는다" do
    get mypage_user_url, headers: NATIVE_HEADERS

    assert_response :success
    assert_select "a[href='#{mypage_plugins_path}']", count: 0
    assert_select "a[href='#{mypage_push_notifications_path}']", count: 0
    assert_select "form[action='#{mypage_theme_path}']", count: 1
    assert_select "form[action='#{mypage_user_path}']", count: 2
    assert_select "form#account_deletion_form", count: 1
    assert_select "form[data-controller~='bridge--form']", count: 1
    assert_select "dl", text: /#{Regexp.escape(@user.name)}/
    assert_select "a[href='#{session_path}'][data-turbo-method='delete']", count: 1
  end

  test "테마를 변경할 수 있다" do
    patch mypage_theme_url, params: { theme: { value: "dark" } }

    assert_response :see_other
    assert_redirected_to mypage_user_path
    assert @user.reload.theme_dark?

    follow_redirect!
    assert_select "html.theme-dark.dark[data-theme-preference-value='dark']"
  end

  test "Turbo Stream으로 테마를 변경하면 flash만 갱신한다" do
    patch mypage_theme_url,
      params: { theme: { value: "light" } },
      headers: turbo_stream_headers

    assert_response :success
    assert @user.reload.theme_light?
    assert_select "turbo-stream[action='update'][target='flash']"
  end

  test "지원하지 않는 테마로 변경할 수 없다" do
    patch mypage_theme_url,
      params: { theme: { value: "unsupported" } },
      headers: turbo_stream_headers

    assert_response :unprocessable_entity
    assert @user.reload.theme_system?
    assert_select "turbo-stream[action='update'][target='flash']"
  end

  test "올바른 현재 비밀번호로 변경하면 재로그인이 필요하다" do
    patch mypage_user_url, params: {
      user: {
        current_password: "password123",
        password: "newpassword456",
        password_confirmation: "newpassword456",
        admin: false
      }
    }
    assert_response :see_other
    assert_redirected_to new_session_path
    assert @user.reload.admin?
    follow_redirect!
    assert_equal I18n.t("settings.password.updated_please_login"), flash[:notice]
  end

  test "잘못된 현재 비밀번호로 변경하면 실패한다" do
    patch mypage_user_url, params: {
      user: { current_password: "wrong", password: "newpassword456", password_confirmation: "newpassword456" }
    }
    assert_response :unprocessable_entity
    assert_select "#flash", text: /#{I18n.t("settings.password.current_password_incorrect")}/
    assert @user.reload.authenticate("password123")
  end

  test "비밀번호 확인이 일치하지 않으면 실패한다" do
    patch mypage_user_url, params: {
      user: { current_password: "password123", password: "newpassword456", password_confirmation: "mismatch" }
    }
    assert_response :unprocessable_entity
    assert_select "#flash", text: /비밀번호.*일치하지 않습니다/
    assert @user.reload.authenticate("password123")
  end

  test "올바른 현재 비밀번호로 회원 탈퇴할 수 있다" do
    other_session = @user.sessions.create!(user_agent: "other", ip_address: "127.0.0.2")
    PushRegistration.create!(
      user: @user,
      session: other_session,
      firebase_installation_id: "account-deletion-installation",
      platform: "ios",
      last_registered_at: Time.current
    )
    PushNotificationSetting.create!(user: @user, plugin_name: "todos", item_key: "due_date_reminder")
    PushNotificationLog.create!(user: @user, title: "알림", body: "본문", requested_at: Time.current)
    UserPlugin.create!(user: @user, plugin_name: "posts", enabled: false, disabled_at: Time.current)
    Journal::Post.create!(body: "삭제 대상", user_id: @user.id)
    Todo::List.create!(title: "삭제 대상", user_id: @user.id).items.create!(title: "삭제 대상")

    delete mypage_user_url, params: {
      user: { id: users(:other_user).id, current_password: "password123" }
    }

    assert_response :see_other
    assert_redirected_to root_path
    assert_not User.exists?(@user.id)
    assert User.exists?(users(:other_user).id)
    assert_equal 0, Session.where(user_id: @user.id).count
    assert_equal 0, PushRegistration.where(user_id: @user.id).count
    assert_equal 0, PushNotificationSetting.where(user_id: @user.id).count
    assert_equal 0, PushNotificationLog.where(user_id: @user.id).count
    assert_equal 0, UserPlugin.where(user_id: @user.id).count
    assert_equal 0, Journal::Post.where(user_id: @user.id).count
    assert_equal 0, Todo::List.where(user_id: @user.id).count

    follow_redirect!
    assert_equal I18n.t("settings.account_deletion.deleted"), flash[:notice]

    get mypage_user_url
    assert_redirected_to new_session_path
  end

  test "잘못된 현재 비밀번호로 회원 탈퇴할 수 없다" do
    Journal::Post.create!(body: "유지 대상", user_id: @user.id)
    Todo::List.create!(title: "유지 대상", user_id: @user.id)

    assert_no_difference [
      -> { User.count },
      -> { Journal::Post.count },
      -> { Todo::List.count }
    ] do
      delete mypage_user_url, params: { user: { current_password: "wrong" } }
    end

    assert_response :unprocessable_entity
    assert_select "#flash", text: /#{Regexp.escape(I18n.t("settings.account_deletion.current_password_incorrect"))}/
    assert_select "#account_deletion_current_password[value]", count: 0
  end

  test "현재 비밀번호 파라미터가 없어도 회원 탈퇴할 수 없다" do
    assert_no_difference "User.count" do
      delete mypage_user_url
    end

    assert_response :unprocessable_entity
    assert_select "#flash", text: /#{Regexp.escape(I18n.t("settings.account_deletion.current_password_incorrect"))}/
  end
end
