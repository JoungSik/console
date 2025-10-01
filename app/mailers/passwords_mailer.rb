class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: t("emails.password_reset.subject"), to: user.email_address
  end
end
