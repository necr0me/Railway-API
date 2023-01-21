class UserPolicy < ApplicationPolicy
  def show?
    owned? || user&.moderator? || user&.admin?
  end

  def update?
    owned?
  end

  def destroy?
    owned? || user&.admin?
  end

  private

  def owned?
    user&.id == record&.id
  end
end
