class SeatSerializer
  include JSONAPI::Serializer

  has_one :ticket, if: proc { |_, params| params.blank? || params[:include_ticket] }
  belongs_to :carriage

  attributes :id, :is_taken
  attribute :number do |object|
    format("%02d", object.number)
  end
end
