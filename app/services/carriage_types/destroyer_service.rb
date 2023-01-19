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
      begin
        if type.carriages.count.zero?
          type.destroy!
          return OpenStruct.new(success?: true, errors: nil)
        else
          return OpenStruct.new(success?: false, errors: ["Can't destroy carriage type that has any carriages"])
        end
      rescue => e
        return OpenStruct.new(success?: false, errors: [e.message])
      end
    end
  end
end
