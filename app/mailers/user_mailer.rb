class UserMailer < ApplicationMailer
  def account_activation(user)
    @user = user
    mail(to: user.unconfirmed_email, subject: "Account activation") do |format|
      format.text(content_transfer_encoding: "7bit")
      format.html(content_transfer_encoding: "7bit")
    end
  end

  def reset_email(user)
    @user = user
    mail(to: user.unconfirmed_email, subject: "Email reset") do |format|
      format.text(content_transfer_encoding: "7bit")
      format.html(content_transfer_encoding: "7bit")
    end
  end

  def reset_password(user)
    @user = user
    mail(to: user.email, subject: "Password reset") do |format|
      format.text(content_transfer_encoding: "7bit")
      format.html(content_transfer_encoding: "7bit")
    end
  end
end
