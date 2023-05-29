module Admin
  class AdminPolicy < ApplicationPolicy
    # TODO: move all methods here

    protected

    def moderator_or_admin?
      user&.moderator? || user&.admin?
    end
  end
end
