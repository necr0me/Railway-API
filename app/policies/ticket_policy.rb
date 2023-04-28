class TicketPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def destroy?
    owned_by_user?
  end

  private

  def owned_by_user?
    user&.id == record&.profile&.user_id
  end
end
