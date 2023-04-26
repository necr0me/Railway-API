class UserPolicy < ApplicationPolicy
  def create?
    user.nil?
  end

  def show?
    owned?
  end

  def update?
    owned?
  end

  def destroy?
    owned?
  end

  private

  def owned?
    user&.id == record&.id
  end
end
