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
      begin
        station_order_number = StationOrderNumber.create!(route_id: route_id,
                                                          station_id: station_id)
        return OpenStruct.new(success?: true, data: station_order_number.station, errors: nil)
      rescue => e
        return OpenStruct.new(success?: false, data: nil, errors: [e.message])
      end
    end
  end
end
