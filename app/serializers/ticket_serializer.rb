class TicketSerializer
  include JSONAPI::Serializer

  belongs_to :seat

  attributes :price, :arrival_time, :departure_time
end
