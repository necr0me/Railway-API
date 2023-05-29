module Routes
  class StationAdderService < ApplicationService
    def initialize(route_id:, station_id:)
      @route_id = route_id
      @station_id = station_id
    end

    def call
      add_station!
    end

    private

    attr_reader :route_id, :station_id

    def add_station!
      station_order_number = StationOrderNumber.create!(route_id: route_id, station_id: station_id)
      update_destination!
      success!(data: station_order_number.station)
    end

    def update_destination!
      Route.find(route_id).tap do |route|
        route.update(destination: "#{route.stations.first&.name} - #{route.stations.last&.name}")
      end
    end
  end
end
