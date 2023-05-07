class TrainStopSerializer
  include JSONAPI::Serializer

  belongs_to :station
  belongs_to :train

  attribute :name do |object|
    object.station.name
  end
  attributes :arrival_time, :departure_time, :way_number
end
