module Admin
  class AdminPolicy < ApplicationPolicy
    protected

    def moderator_or_admin?
      user&.moderator? || user&.admin?
    end
  end
end
