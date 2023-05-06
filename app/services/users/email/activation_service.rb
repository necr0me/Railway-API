# frozen_string_literal: true

module Users
  module Email
    class ActivationService < ApplicationService
      def initialize(token:)
        @token = token
      end

      def call
        activate
      end

      private

      attr_reader :token

      def activate
        return fail!(error: { confirmation_token: ["Token is not presented"] }) if token.blank?

        @user = User.find_by(confirmation_token: token)
        return fail!(error: { confirmation_token: ["Confirmation token is invalid"] }) if @user.blank?

        return fail!(error: @user.errors) unless update_user

        success!(data: @user)
      end

      def update_user
        @user.email = @user.unconfirmed_email
        @user.activated = true
        @user.unconfirmed_email = nil
        @user.confirmation_token = nil
        @user.save
      end
    end
  end
end
