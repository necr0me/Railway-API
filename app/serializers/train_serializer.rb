class TrainSerializer
  include JSONAPI::Serializer

  attribute :destination do |train|
    train.route&.destination.present? ? train.destination : "-"
  end
end
