class StationSerializer
  include JSONAPI::Serializer

  has_many :train_stops

  attributes :name, :number_of_ways
end
