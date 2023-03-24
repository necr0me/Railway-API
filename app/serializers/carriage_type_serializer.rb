class CarriageTypeSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :capacity
end
