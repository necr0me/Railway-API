module CarriageTypes
  class UpdaterService < ApplicationService
    def initialize(carriage_type:, carriage_type_params:)
      @type = carriage_type
      @params = carriage_type_params
    end

    def call
      update
    end

    private

    attr_reader :type, :params

    def update
      if type.capacity == params[:capacity] || type.carriages.count.zero?
        type.update(params)
        type.errors.empty? ? success!(data: type) : fail!(error: type.errors.to_hash(full_messages: true))
      else
        fail!(error: { capacity: ["Невозможно обновить вместительность типа, у которого есть хотя бы один вагон"] })
      end
    end
  end
end
