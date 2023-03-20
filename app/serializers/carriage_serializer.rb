class CarriageSerializer
  include JSONAPI::Serializer

  has_many :seats, if: Proc.new { _1.seats.any? }
  attributes :name, :order_number
end
