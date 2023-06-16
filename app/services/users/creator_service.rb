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
      return fail!(error: { unconfirmed_email: ["Email пуст"] }) if user_params[:unconfirmed_email].blank?

      user = User.new(user_params)
      return fail!(error: errors_for(user)) unless user.valid?

      user.confirmation_token = TokenGeneratorService.call.data
      return fail!(error: errors_for(user)) unless user.save

      UserMailer.account_activation(user).deliver_now
      success!
    end

    def errors_for(user)
      user.errors.to_hash(full_messages: true).merge(unconfirmed_email: user.errors[:unconfirmed_email])
    end
  end
end
