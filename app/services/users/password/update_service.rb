# frozen_string_literal: true

module Users
  module Password
    class UpdateService < ApplicationService
      def initialize(token:, password:)
        @token = token
        @password = password
      end

      def call
        update
      end

      private

      attr_reader :token, :password

      def update
        return fail!(error: { reset_password_token: ["Token is not presented"] }) if token.blank?

        @user = User.find_by(reset_password_token: token)
        return fail!(error: { reset_password_token: ["Token is invalid"] }) if @user.blank?

        return fail!(error: { reset_password_token: ["Token has expired"] }) if token_expired?

        return fail!(error: { password: ["New password is the same as old one"] }) if @user.authenticate(password)

        return fail!(error: @user.errors) unless update_user

        success!
      end

      def token_expired?
        (@user.reset_password_sent_at + 4.hours) < Time.now.utc
      end

      def update_user
        @user.reset_password_token = nil
        @user.reset_password_sent_at = nil

        @user.password = password

        @user.save
      end
    end
  end
end
