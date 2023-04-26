module Admin
  class RoutePolicy < AdminPolicy
    def index?
      moderator_or_admin?
    end

    def show?
      moderator_or_admin?
    end

    def create?
      moderator_or_admin?
    end

    def add_station?
      moderator_or_admin?
    end

    def remove_station?
      moderator_or_admin?
    end

    def destroy?
      moderator_or_admin?
    end
  end
end
