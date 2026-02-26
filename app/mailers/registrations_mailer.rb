class RegistrationsMailer < ApplicationMailer
  def verify(user)
    @user = user
    mail subject: t("emails.email_verification.subject"), to: user.email_address
  end
end
