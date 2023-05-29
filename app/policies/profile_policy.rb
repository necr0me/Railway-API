class ProfilePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    owned_by_user?
  end

  def destroy?
    owned_by_user?
  end
end
