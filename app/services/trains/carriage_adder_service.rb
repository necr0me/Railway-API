module Trains
  class CarriageAdderService < ApplicationService
    def initialize(train:, carriage_id: )
      @train = train
      @carriage_id = carriage_id
    end

    def call
      add_carriage
    end

    private

    attr_reader :train, :carriage_id

    def add_carriage
      begin
        carriage = Carriage.find(carriage_id)
        return OpenStruct.new(success?: false,
                              data: nil,
                              errors: ['Carriage already in train']) unless carriage.train_id.nil?
        carriage.update!(train_id: train.id,
                         order_number: train.carriages.count + 1)
        return OpenStruct.new(success?: true, data: carriage, errors: nil)
      rescue => e
        return OpenStruct.new(success?: false, data: nil, errors: [e.message])
      end
    end
  end
end