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
      station_order_number = StationOrderNumber.create!(route_id: route_id,
                                                        station_id: station_id)
      success!(data: station_order_number.station)
    end
  end
end
