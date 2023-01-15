class StationPolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    true
  end

  def create?
    moderator_or_admin?
  end

  def update?
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
