class TrainSerializer
  include JSONAPI::Serializer

  has_many :carriages
  has_many :stops, serializer: TrainStopSerializer
  has_one :route

  attribute :destination do |train|
    train.route&.destination.present? ? train.destination : "No destination"
  end

  attribute :travel_time do |train|
    ActiveSupport::Duration.build(train.travel_time).iso8601(precision: 0)
  end
end
