class RouteSerializer
  include JSONAPI::Serializer

  attribute :destination do |route|
    route.destination.empty? ? "Нет" : route.destination
  end

  attribute :standard_travel_time do |route|
    route.standard_travel_time.iso8601
  end

  has_many :stations
end
