module Trains
  class DestroyerService < ApplicationService
    def initialize(train:)
      @train = train
    end

    def call
      destroy
    end

    private

    attr_reader :train

    def destroy
      train.transaction do
        train.carriages.preload(:seats).each { |carriage| carriage.seats.preload(:ticket).destroy_all }
        train.destroy ? success! : fail!(error: train.errors)
      end
    end
  end
end
