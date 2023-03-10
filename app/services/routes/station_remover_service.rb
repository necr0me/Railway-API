module Routes
  class StationRemoverService < ApplicationService
    def initialize(route_id:, station_id:)
      @route_id = route_id
      @station_id = station_id
    end

    def call
      remove_station
    end

    private

    attr_reader :route_id, :station_id

    def remove_station
      station = StationOrderNumber.includes(:route).find_by!(route_id: route_id, station_id: station_id)
      ActiveRecord::Base.transaction do
        decrement_order_numbers_after(station)
        station.destroy!
      end
      success!
    end

    def decrement_order_numbers_after(station)
      station.route.station_order_numbers.where('order_number > ?', station.order_number)
             .each { _1.update(order_number: _1.order_number - 1) }
    end
  end
end
