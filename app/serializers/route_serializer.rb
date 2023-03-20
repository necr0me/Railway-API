class RouteSerializer
  include JSONAPI::Serializer

  has_many :stations
end
