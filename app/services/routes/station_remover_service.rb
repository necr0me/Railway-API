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
      station_order_number = StationOrderNumber.preload(:route, route: :trains)
                                               .find_by!(route_id: route_id, station_id: station_id)
      ActiveRecord::Base.transaction do
        decrement_order_numbers_after(station_order_number)
        remove_stops(station_order_number)
        station_order_number.destroy!
        update_destination!(station_order_number.route)
      end
      success!(data: station_order_number.station)
    end

    def decrement_order_numbers_after(station_order_number)
      station_order_number.route.station_order_numbers.where("order_number > ?", station_order_number.order_number)
                          .each { _1.update(order_number: _1.order_number - 1) }
    end

    def remove_stops(station_order_number)
      station_order_number.route.trains.preload(:stops)
                          .each { |train| train.stops.where(station_id: station_order_number.station_id).destroy_all }
    end

    def update_destination!(route)
      destination = route.stations.empty? ? "" : "#{route.stations.first.name} - #{route.stations.last.name}"
      route.update!(destination: destination)
    end
  end
end
