module Trains
  class CarriageRemoverService < ApplicationService
    def initialize(train:, carriage_id: )
      @train = train
      @carriage_id = carriage_id
    end

    def call
      remove_carriage
    end

    private

    attr_reader :train, :carriage_id

    def remove_carriage
      begin
        carriage = Carriage.find(carriage_id)
        return OpenStruct.new(success?: false,
                              errors: ["Can't remove carriage that not in train"]) if carriage.train_id.nil?
        return OpenStruct.new(success?: false,
                              errors: ["Can't remove carriage from different train"]) if carriage.train_id != train.id
        ActiveRecord::Base.transaction do
          train.carriages.where("order_number > ?", carriage.order_number)
               .update_counters(order_number: -1)
          carriage.update!(train_id: nil,
                           order_number: nil)
          carriage.seats.destroy_all
        end
        return OpenStruct.new(success?: true, errors: nil)
      rescue => e
        return OpenStruct.new(success?: false, errors: [e.message])
      end
    end
  end
end