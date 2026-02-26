class RegistrationsMailerPreview < ActionMailer::Preview
  def verify
    user = User.first || User.new(
      email_address: "user@example.com",
      name: "홍길동"
    )
    RegistrationsMailer.verify(user)
  end
end
