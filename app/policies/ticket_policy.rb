class TicketPolicy < ApplicationPolicy
  def show?
    owned? || moderator_or_admin?
  end

  def create?
    user.present?
  end

  def destroy?
    owned? || user&.admin?
  end

  private

  def owned?
    user&.id == record&.user_id
  end

  def moderator_or_admin?
    user&.moderator? || user&.admin?
  end
end
