class TrainSerializer
  include JSONAPI::Serializer

  has_many :carriages

  attribute :destination do |train|
    train.route&.destination.present? ? train.destination : "No destination"
  end
end
