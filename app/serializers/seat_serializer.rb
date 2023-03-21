class SeatSerializer
  include JSONAPI::Serializer

  attributes :id, :number, :is_taken
end
