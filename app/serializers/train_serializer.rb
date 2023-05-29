class TrainSerializer
  include JSONAPI::Serializer

  has_many :carriages
  has_many :stops, serializer: TrainStopSerializer
  has_one :route

  attribute :destination do |train|
    train.route&.destination.present? ? train.destination : "No destination"
  end
end
