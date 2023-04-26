class TicketPolicy < ApplicationPolicy
  def show?
    owned_by_user?
  end

  def create?
    user.present?
  end

  def destroy?
    owned_by_user?
  end
end
