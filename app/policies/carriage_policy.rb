class CarriagePolicy < ApplicationPolicy
  def show?
    user.present?
  end
end
