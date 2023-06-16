class UserMailerPreview < ActionMailer::Preview
  def account_activation
    UserMailer.account_activation(User.new(unconfirmed_email: "johndoe@gmail.com", confirmation_token: "token"))
  end

  def reset_email
    UserMailer.reset_email(User.new(email: "johndoe@gmail.com", reset_email_token: "token"))
  end

  def reset_password
    UserMailer.reset_password(User.new(email: "johndoe@gmail.com", reset_password_token: "token"))
  end
end
