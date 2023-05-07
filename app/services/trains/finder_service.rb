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

    # TODO: should return pair of PassingTrains (DONE)
    # think about queries performance
    def find_trains
      query = TrainStop.preload(:train, :station)
      query = query.send("arrives_#{day_option}", Time.at(date.to_i).to_datetime) unless date.nil?

      query = if departure_station.present? && arrival_station.present?
                trains_between_stations(query)
              elsif departure_station.present? || arrival_station.present?
                query.where(station_id: (departure_station || arrival_station).id)
              else
                query.where(id: Train.includes(:stops).all.map { _1.stops&.first }.compact.pluck(:id))
              end
      success!(data: finalize_result(query))
    end

    def trains_between_stations(query)
      final_station_trains = query.where(station_id: arrival_station.id)
      passing_trains = query.where(station_id: departure_station.id).where(
        train_id: final_station_trains.pluck(:train_id)
      )
      to_remove = collect_train_ids(passing_trains, final_station_trains)
      passing_trains.where.not(train_id: to_remove)
    end

    def collect_train_ids(passing_trains, final_station_trains)
      passing_trains.inject([]) do |memo, passing_train, train_id = passing_train.train_id|
        train = final_station_trains.find_by(train_id: train_id)
        memo.push(train_id) if train.arrival_time < passing_train.departure_time
      end
    end

    def finalize_result(query)
      pair_for = pair_func # TODO: benchmark with bigger DB
      passing_trains = query.inject([]) { |memo, passing_train| memo.push(pair_for[passing_train]) }
      {
        departure_station: departure_station,
        arrival_station: arrival_station,
        passing_trains: passing_trains
      }
    end

    def pair_func
      if departure_station.present? && arrival_station.present?
        proc { |stop| [stop, arrival_station.train_stops.find_by(train_id: stop.train_id)] }
      elsif arrival_station.present?
        proc { |stop| [stop.train.stops.first, stop] }
      else
        proc { |stop| [stop, stop.train.stops.last] }
      end
    end
  end
end
