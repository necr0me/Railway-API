class TrainPolicy < ApplicationPolicy
  def show?
    user.present?
  end
end
