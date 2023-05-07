class SeatSerializer
  include JSONAPI::Serializer

  belongs_to :carriage

  attributes :id, :is_taken
  attribute :number do |object|
    format("%02d", object.number)
  end
end
