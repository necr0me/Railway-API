module CarriageTypes
  class DestroyerService < ApplicationService
    def initialize(carriage_type:)
      @type = carriage_type
    end

    def call
      destroy
    end

    private

    attr_reader :type

    def destroy
      return fail!(error: "Невозможно удалить тип у которого есть хотя бы один вагон") if type.carriages.count.nonzero?

      type.destroy!
      success!
    end
  end
end
