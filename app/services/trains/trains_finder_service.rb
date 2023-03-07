module Trains
  class TrainsFinderService < ApplicationService
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
      @ending_station = Station.find_by(name: ending_station)
    end

    # TODO: should return pair of PassingTrains
    # 1st one is when train departs from starting station and 2nd one is when train arrives to finish station
    # (if such station exists)
    def find_trains
      query = PassingTrain.joins(:train, :station)
      query = query.send("arrives_#{day_option}", date) unless date.nil?
      if starting_station.present? && ending_station.present?
        query = trains_between_stations(query)
      elsif starting_station.present? || ending_station.present?
        query = query.where(station_id: (starting_station || ending_station).id)
      end
      success!(data: query)
    end

    def trains_between_stations(query)
      passing_trains = query.where(station_id: starting_station.id).where(
        train_id: query.where(station_id: ending_station.id).pluck(:train_id)
      )
      trains_ids = passing_trains.pluck(:train_id)
      ending_station_trains = ending_station.passing_trains.where(train_id: trains_ids)
      to_remove = passing_trains.inject([]) do |memo, passing_train|
        train_id = passing_train.train_id
        train = ending_station_trains.find_by(train_id: train_id)
        memo.push(train_id) if train.arrival_time < passing_train.departure_time
      end
      passing_trains.where.not(train_id: to_remove)
    end
  end
end
