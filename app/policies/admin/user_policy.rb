module Admin
  class UserPolicy < AdminPolicy
    def destroy?
      user&.admin?
    end
  end
end
