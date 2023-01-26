module CarriageTypes
  class DestroyerService < ApplicationService
    def initialize(carriage_type: )
      @type = carriage_type
    end

    def call
      destroy
    end

    private

    attr_reader :type

    def destroy
      if type.carriages.count.zero?
        type.destroy!
        success!
      else
        fail!(error: "Can't destroy carriage type that has any carriages")
      end
    rescue => e
      fail!(error: e.message)
    end
  end
end
