require "test_helper"

class WelcomeMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = users(:test_user)
    mail = WelcomeMailer.welcome(user)

    assert_equal [ "support@joungsik.com" ], mail.from
    assert_equal [ user.email_address ], mail.to
    assert_equal I18n.t("emails.welcome.subject"), mail.subject

    # HTML 본문 검증
    html_body = mail.html_part.body.to_s
    assert_includes html_body, user.name
    assert_includes html_body, I18n.t("emails.welcome.get_started")

    # TEXT 본문 검증
    text_body = mail.text_part.body.to_s
    assert_includes text_body, user.name
    assert_includes text_body, I18n.t("emails.welcome.get_started")
  end
end
