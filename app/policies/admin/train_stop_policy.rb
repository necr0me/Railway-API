module Admin
  class TrainStopPolicy < AdminPolicy
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
