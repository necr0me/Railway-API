class RouteSerializer
  include JSONAPI::Serializer

  attribute :destination do |route|
    route.destination.nil? ? "No destination" : route.destination
  end

  has_many :stations
end
