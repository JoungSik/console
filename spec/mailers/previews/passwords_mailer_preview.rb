class PasswordsMailerPreview < ActionMailer::Preview
  def reset
    user = User.first || User.new(
      email_address: "user@example.com",
      name: "홍길동"
    )
    PasswordsMailer.reset(user)
  end
end