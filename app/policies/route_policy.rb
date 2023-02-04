class RoutePolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    moderator_or_admin?
  end

  def add_station?
    moderator_or_admin?
  end

  def remove_station?
    moderator_or_admin?
  end

  def destroy?
    moderator_or_admin?
  end

  private

  def moderator_or_admin?
    user&.moderator? || user&.admin?
  end
end
