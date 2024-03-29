# frozen_string_literal: true

module Users
  module Password
    class ResetService < ApplicationService
      def initialize(email:)
        @email = email
      end

      def call
        reset_password
      end

      private

      attr_reader :email

      def reset_password
        @user = User.find_by(unconfirmed_email: email)
        @user ||= User.find_by(email: email)
        return fail!(error: { email: ["Пользователь с данным email не зарегистрирован"] }) if @user.blank?
        return fail!(error: { email: ["Аккаунт не активирован"] }) unless @user.activated?

        return fail!(error: @user.errors.to_hash(full_messages: true)) unless update_user

        UserMailer.reset_password(@user).deliver_now
        success!
      end

      def update_user
        @user.reset_password_token = TokenGeneratorService.call.data
        @user.reset_password_sent_at = DateTime.now.utc

        @user.save
      end
    end
  end
end
