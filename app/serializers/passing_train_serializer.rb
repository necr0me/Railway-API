class PassingTrainSerializer
  include JSONAPI::Serializer

  belongs_to :station
  belongs_to :train

  attributes :arrival_time, :departure_time, :way_number
end
