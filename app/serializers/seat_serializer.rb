class SeatSerializer
  include JSONAPI::Serializer

  attributes :id, :is_taken
  attribute :number do |object|
    "%02d" % object.number
  end
end
