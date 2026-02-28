class WelcomeMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail subject: t("emails.welcome.subject"), to: user.email_address
  end
end
