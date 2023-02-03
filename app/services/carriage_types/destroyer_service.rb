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
      return fail!(error: "Can't destroy carriage type that has any carriages") if type.carriages.count.nonzero?

      type.destroy!
      success!
    end
  end
end
