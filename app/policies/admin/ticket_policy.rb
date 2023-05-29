module Admin
  class TicketPolicy < AdminPolicy
    def destroy?
      user&.admin?
    end
  end
end
