class CarriageSerializer
  include JSONAPI::Serializer

  has_many :seats, if: proc { _1.seats.any? }

  attributes :name, :capacity

  attribute :type do |object|
    object.type.name
  end
end
