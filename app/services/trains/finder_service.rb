module Trains
  class FinderService < ApplicationService
    def initialize(departure_station:, arrival_station:, date: nil, day_option: :at_the_day)
      @departure_station = departure_station
      @arrival_station = arrival_station
      @date = date
      @day_option = day_option
    end

    def call
      set_stations!
      find_trains
    end

    private

    attr_reader :departure_station, :arrival_station, :date, :day_option

    def set_stations!
      @departure_station = Station.find_by(name: departure_station)
      @arrival_station = Station.preload(:train_stops).find_by(name: arrival_station)
    end

    def find_trains
      query = TrainStop.preload(train: :stops)
      query = if departure_station.present? && arrival_station.present?
                trains_between_stations(query)
              elsif departure_station.present? || arrival_station.present?
                query.where(station_id: (departure_station || arrival_station).id)
              else
                query
              end
      query = query.send("arrives_#{day_option}", Time.at(date.to_i).utc) unless date.nil?
      success!(data: finalize_result(query))
    end

    def trains_between_stations(query)
      arrival_stops = query.where(station_id: arrival_station.id)
      departure_stops = query.where(station_id: departure_station.id)
                             .where(train_id: arrival_stops.pluck(:train_id))
      invalid_stops_trains_ids = find_invalid_stops(arrival_stops, departure_stops)
      departure_stops.where.not(train_id: invalid_stops_trains_ids)
    end

    def find_invalid_stops(arrival_stops, departure_stops)
      departure_stops.inject([]) do |array, stop, train_id = stop.train_id|
        other_stop = arrival_stops.find_by(train_id: train_id)
        array << other_stop if other_stop.arrival_time < stop.departure_time
      end&.pluck(:train_id)
    end

    def finalize_result(query)
      query = query.select { _1.train.free? && _1.train.travels? }
      function = build_pair
      {
        departure_station: departure_station,
        arrival_station: arrival_station,
        trains: query.inject([]) { _1 << function[_2] }.compact
      }
    end

    def build_pair
      if departure_station.present? && arrival_station.present?
        proc { |stop| [stop, arrival_station.train_stops.find_by(train_id: stop.train_id)] }
      elsif departure_station.present?
        proc { |stop| stop.last? ? nil : [stop, stop.train.last_stop] }
      elsif arrival_station.present?
        proc { |stop| stop.first? ? nil : [stop.train.first_stop, stop] }
      else
        proc { nil }
      end
    end
  end
end
