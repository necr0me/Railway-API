module TrainStops
  class WayCheckerService < ApplicationService
    def initialize(station:, train_stop:)
      @station = station
      @train_stop = train_stop
    end

    def call
      check
    end

    private

    attr_reader :station, :train_stop

    def check
      stops = station.train_stops.where(way_number: train_stop.way_number).where.not(id: train_stop.id)
      return success! if stops.empty?

      empty = stops.all? do |stop|
        before_arrival?(stop) || after_departure?(stop)
      end

      empty ? success! : fail!(error: { way_number: ["#{train_stop.way_number} is taken"] })
    end

    def before_arrival?(stop)
      train_stop.arrival_time < stop.arrival_time && train_stop.departure_time < stop.arrival_time
    end

    def after_departure?(stop)
      train_stop.arrival_time > stop.departure_time && train_stop.departure_time > stop.departure_time
    end
  end
end
