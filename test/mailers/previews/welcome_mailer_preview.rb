class WelcomeMailerPreview < ActionMailer::Preview
  def welcome
    user = User.new(
      email_address: "user@example.com",
      name: "홍길동"
    )
    WelcomeMailer.welcome(user)
  end
end
