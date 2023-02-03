module Trains
  class CarriageAdderService < ApplicationService
    def initialize(train:, carriage_id:)
      @train = train
      @carriage_id = carriage_id
    end

    def call
      add_carriage
    end

    private

    attr_reader :train, :carriage_id

    def add_carriage
      carriage = Carriage.find(carriage_id)
      return fail!(error: 'Carriage already in train') if carriage.train_id.present?

      ActiveRecord::Base.transaction do
        carriage.update!(train_id: train.id, order_number: train.carriages.count + 1)
        create_seats_for(carriage)
      end
      success!(data: carriage)
    end

    def create_seats_for(carriage)
      carriage.capacity.times do |i|
        Seat.create!(number: i + 1,
                     carriage_id: carriage.id)
      end
    end
  end
end
