class CarriageSerializer
  include JSONAPI::Serializer

  attributes :name, :capacity, :carriage_type_id

  attribute :available do |object|
    object.train_id.nil? ? true : false
  end

  attribute :type do |object|
    object.type.name
  end
end
