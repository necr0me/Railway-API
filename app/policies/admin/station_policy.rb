module Admin
  class StationPolicy < AdminPolicy
    def index?
      moderator_or_admin?
    end

    def show?
      moderator_or_admin?
    end

    def create?
      moderator_or_admin?
    end

    def update?
      moderator_or_admin?
    end

    def destroy?
      moderator_or_admin?
    end
  end
end
