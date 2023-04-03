class TicketSerializer
  include JSONAPI::Serializer

  has_one :arrival_station, serializer: StationSerializer
  has_one :departure_station, serializer: StationSerializer

  belongs_to :seat

  attributes :price
end
