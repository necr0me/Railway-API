class CarriageSerializer
  include JSONAPI::Serializer

  belongs_to :train

  has_many :seats, if: Proc.new { |_, params| params.blank? ? true : params[:include_seats] }

  attributes :name, :capacity, :carriage_type_id

  attribute :order_number, if: Proc.new { |carriage| carriage.order_number.present? } do |object|
    format("%02d", object.order_number)
  end

  attribute :available do |object|
    object.train_id.nil? ? true : false
  end

  attribute :type do |object|
    object.type.name
  end
end
