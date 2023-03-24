module Trains
  require "benchmark"

  class FinderService < ApplicationService
    def initialize(starting_station:, ending_station:, date: nil, day_option: :at_the_day)
      @starting_station = starting_station
      @ending_station = ending_station
      @date = date
      @day_option = day_option
    end

    def call
      set_stations!
      find_trains
    end

    private

    attr_reader :starting_station, :ending_station, :date, :day_option

    def set_stations!
      @starting_station = Station.find_by(name: starting_station)
      @ending_station = Station.preload(:passing_trains).find_by(name: ending_station)
    end

    # TODO: should return pair of PassingTrains (DONE)
    # think about queries performance
    def find_trains
      query = PassingTrain.preload(:train, :station)
      query = query.send("arrives_#{day_option}", date) unless date.nil?

      query = if starting_station.present? && ending_station.present?
                trains_between_stations(query)
              elsif starting_station.present? || ending_station.present?
                query.where(station_id: (starting_station || ending_station).id)
              else
                query.where(id: Train.includes(:stops).all.map { _1.stops&.first }.compact.pluck(:id))
              end
      success!(data: finalize_result(query))
    end

    def trains_between_stations(query)
      final_station_trains = query.where(station_id: ending_station.id)
      passing_trains = query.where(station_id: starting_station.id).where(
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
        starting_station: starting_station,
        ending_station: ending_station,
        passing_trains: passing_trains
      }
    end

    def pair_func
      if starting_station.present? && ending_station.present?
        proc { |stop| [stop, ending_station.passing_trains.find_by(train_id: stop.train_id)] }
      elsif ending_station.present?
        proc { |stop| [stop.train.stops.first, stop] }
      else
        proc { |stop| [stop, stop.train.stops.last] }
      end
    end
  end
end
