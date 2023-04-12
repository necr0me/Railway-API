class PassingTrainSerializer
  include JSONAPI::Serializer

  belongs_to :station
  belongs_to :train

  attribute :station_name do |object|
    object.station.name
  end
  attributes :arrival_time, :departure_time, :way_number
end
