class StationSerializer
  include JSONAPI::Serializer

  has_many :train_stops

  attribute :name
end
