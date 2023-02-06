module CarriageTypes
  class UpdaterService < ApplicationService
    def initialize(carriage_type:, carriage_type_params:)
      @type = carriage_type
      @name = carriage_type_params[:name]
      @description = carriage_type_params[:description]
      @capacity = carriage_type_params[:capacity]
    end

    def call
      update
    end

    private

    attr_reader :type, :name, :description, :capacity

    def update
      if type.capacity == capacity || type.carriages.count.zero?
        type.update!(
          name: name,
          description: description,
          capacity: capacity
        )
        success!(data: type)
      else
        fail!(error: "Can't update carriage type capacity that has any carriages")
      end
    end
  end
end
