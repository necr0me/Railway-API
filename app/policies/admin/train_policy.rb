module Admin
  class TrainPolicy < AdminPolicy
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

    def add_carriage?
      moderator_or_admin?
    end

    def remove_carriage?
      moderator_or_admin?
    end

    def destroy?
      moderator_or_admin?
    end
  end
end

