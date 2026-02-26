require "test_helper"

class RegistrationsTest < ActionDispatch::IntegrationTest
  test "회원가입 페이지에 접근할 수 있다" do
    get new_registration_url
    assert_response :success
  end

  test "유효한 정보로 가입하면 verify_pending으로 리다이렉트되고 이메일이 발송된다" do
    assert_enqueued_emails 1 do
      post registration_url, params: {
        user: {
          name: "신규사용자",
          email_address: "new@example.com",
          password: "password1",
          password_confirmation: "password1"
        },
        terms_agreed: "1"
      }
    end

    assert_redirected_to verify_pending_registration_path
  end

  test "약관 미동의 시 가입에 실패한다" do
    post registration_url, params: {
      user: {
        name: "신규사용자",
        email_address: "new@example.com",
        password: "password1",
        password_confirmation: "password1"
      }
    }

    assert_response :unprocessable_entity
  end

  test "비밀번호 강도 부족 시 가입에 실패한다" do
    post registration_url, params: {
      user: {
        name: "신규사용자",
        email_address: "new@example.com",
        password: "weak",
        password_confirmation: "weak"
      },
      terms_agreed: "1"
    }

    assert_response :unprocessable_entity
  end

  test "숫자 없는 비밀번호로 가입에 실패한다" do
    post registration_url, params: {
      user: {
        name: "신규사용자",
        email_address: "new@example.com",
        password: "password",
        password_confirmation: "password"
      },
      terms_agreed: "1"
    }

    assert_response :unprocessable_entity
  end

  test "중복 이메일로 가입에 실패한다" do
    post registration_url, params: {
      user: {
        name: "중복사용자",
        email_address: users(:test_user).email_address,
        password: "password1",
        password_confirmation: "password1"
      },
      terms_agreed: "1"
    }

    assert_response :unprocessable_entity
  end

  test "유효 토큰으로 이메일 인증하면 자동 로그인된다" do
    user = User.create!(
      name: "인증테스트",
      email_address: "verify@example.com",
      password: "password1",
      password_confirmation: "password1"
    )
    token = user.generate_token_for(:email_verification)

    get verify_registration_url(token: token)

    assert_redirected_to root_path
    user.reload
    assert user.email_verified?
  end

  test "이미 인증된 사용자가 인증 링크를 클릭하면 로그인 페이지로 안내된다" do
    user = users(:test_user)
    token = user.generate_token_for(:email_verification)

    get verify_registration_url(token: token)

    assert_redirected_to new_session_path
    assert_equal I18n.t("messages.success.email_already_verified"), flash[:notice]
  end

  test "만료/무효 토큰으로 인증하면 에러가 표시된다" do
    get verify_registration_url(token: "invalid_token")

    assert_redirected_to new_session_path
    assert_equal I18n.t("messages.errors.email_verification_link_invalid"), flash[:alert]
  end

  test "미인증 사용자가 로그인하면 차단되고 인증 이메일이 재발송된다" do
    user = User.create!(
      name: "미인증사용자",
      email_address: "unverified@example.com",
      password: "password1",
      password_confirmation: "password1"
    )

    assert_enqueued_emails 1 do
      post session_url, params: { email_address: "unverified@example.com", password: "password1" }
    end

    assert_redirected_to verify_pending_registration_path
  end

  test "회원가입 rate limiting이 동작한다" do
    6.times do |i|
      post registration_url, params: {
        user: {
          name: "사용자#{i}",
          email_address: "ratelimit#{i}@example.com",
          password: "password1",
          password_confirmation: "password1"
        },
        terms_agreed: "1"
      }
    end

    assert_redirected_to new_registration_url
  end

  test "verify_pending 페이지에 접근할 수 있다" do
    get verify_pending_registration_url
    assert_response :success
  end
end
