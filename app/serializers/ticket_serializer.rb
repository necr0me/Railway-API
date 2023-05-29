class TicketSerializer
  include JSONAPI::Serializer

  belongs_to :seat
  belongs_to :profile

  attribute :train_id do |object|
    object.arrival_point.train_id
  end

  attribute :destination do |object|
    object.arrival_point.train.destination
  end

  attribute :departure_point do |object|
    object.departure_point.station.name
  end

  attribute :arrival_point do |object|
    object.arrival_point.station.name
  end

  attributes :price, :arrival_time, :departure_time
end
