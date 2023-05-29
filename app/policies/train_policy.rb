class TrainPolicy < ApplicationPolicy
  def show?
    user.present?
  end

  def show_stops?
    true
  end
end
