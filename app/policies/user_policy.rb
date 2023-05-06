class UserPolicy < ApplicationPolicy
  def create?
    user.nil?
  end

  def show?
    owned?
  end

  def activate?
    true
  end

  def reset_email?
    user.present?
  end

  def update_email?
    user.present?
  end

  def reset_password?
    true
  end

  def update_password?
    true
  end

  def destroy?
    owned?
  end

  private

  def owned?
    user&.id == record&.id
  end
end
