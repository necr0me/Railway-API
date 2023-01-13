module Routes
  class StationRemoverService < ApplicationService
    def initialize(route_id:, station_id:)
      @route_id = route_id
      @station_id = station_id
    end

    def call
      remove_station!
    end

    private

    attr_reader :route_id, :station_id

    def remove_station!
      begin
        station = StationOrderNumber.includes(:route).find_by!(route_id: route_id, station_id: station_id)
        ActiveRecord::Base.transaction do
          station.route.station_order_numbers.where('order_number > ?', station.order_number)
                 .update_counters(order_number: -1)
          station.destroy!
        end
        return OpenStruct.new(success?: true, errors: nil)
      rescue => e
        return OpenStruct.new(success?: false, errors: [e.message])
      end
    end
  end
end