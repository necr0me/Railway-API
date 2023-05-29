class CarriageTypeSerializer
  include JSONAPI::Serializer

  has_many :carriages

  attributes :name, :description, :capacity, :cost_per_hour
end
