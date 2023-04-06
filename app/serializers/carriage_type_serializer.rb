class CarriageTypeSerializer
  include JSONAPI::Serializer

  has_many :carriages

  attributes :name, :description, :capacity
end
