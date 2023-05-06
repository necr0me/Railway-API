module Users
  module Email
    class ResetService < ApplicationService
      def initialize(user:)
        @user = user
      end

      def call
        reset
      end

      private

      attr_reader :user

      def reset
        if update_user
          UserMailer.reset_email(user).deliver_now
          success!
        else
          fail!(error: user.errors)
        end
      end

      def update_user
        user.reset_email_token = TokenGeneratorService.call.data
        user.reset_email_sent_at = DateTime.now.utc
        user.save
      end
    end
  end
end
