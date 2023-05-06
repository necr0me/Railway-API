module Users
  module Email
    class UpdateService < ApplicationService
      def initialize(token:, email:)
        @token = token
        @email = email
      end

      def call
        update
      end

      private

      attr_reader :token, :email

      def update
        return fail!(error: { reset_email_token: ["Token is not presented"] }) if token.blank?

        @user = User.find_by(reset_email_token: token)
        return fail!(error: { reset_email_token: ["Token is invalid"] }) if @user.blank?

        return fail!(error: { reset_email_token: ["Token has expired"] }) if token_expired?

        return fail!(error: { unconfirmed_email: ["New email same as old one"] }) if @user.email == email

        return fail!(error: @user.errors) unless update_user

        UserMailer.account_activation(@user).deliver_now
        success!
      end

      def token_expired?
        (@user.reset_email_sent_at.utc + 4.hours) < Time.now.utc
      end

      def update_user
        @user.unconfirmed_email = email
        @user.confirmation_token = TokenGeneratorService.call.data

        @user.reset_email_token = nil
        @user.reset_email_sent_at = nil

        @user.save
      end
    end
  end
end
