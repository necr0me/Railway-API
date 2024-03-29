module Trains
  class CarriageRemoverService < ApplicationService
    def initialize(train:, carriage_id:)
      @train = train
      @carriage_id = carriage_id
    end

    def call
      remove_carriage
    end

    private

    attr_reader :train, :carriage_id

    def remove_carriage
      carriage = Carriage.find(carriage_id)
      return fail!(error: "Невозможно удалить вагона из состава поезда, в котором его нет") if carriage.train_id.nil?
      return fail!(error: "Невозможно удалить вагон из другого состава поезда") if carriage.train_id != train.id

      ActiveRecord::Base.transaction do
        decrement_order_numbers_after(carriage)
        carriage.update!(train_id: nil, order_number: nil)
        carriage.seats.destroy_all
      end
      success!(data: carriage)
    end

    def decrement_order_numbers_after(carriage)
      train.carriages.where("order_number > ?", carriage.order_number)
           .each { _1.update(order_number: _1.order_number - 1) }
    end
  end
end
