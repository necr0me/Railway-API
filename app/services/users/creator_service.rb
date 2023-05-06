module Users
  class CreatorService < ApplicationService
    def initialize(user_params:)
      @user_params = user_params
    end

    def call
      create
    end

    private

    attr_reader :user_params

    def create
      return fail!(error: { unconfirmed_email: ["Email is blank"] }) if user_params[:unconfirmed_email].blank?

      user = User.new(user_params)
      return fail!(error: user.errors) unless user.valid?

      user.confirmation_token = TokenGeneratorService.call.data
      return fail!(error: user.errors) unless user.save

      UserMailer.account_activation(user).deliver_now
      success!
    end
  end
end
