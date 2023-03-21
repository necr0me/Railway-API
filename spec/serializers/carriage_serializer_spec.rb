require 'rails_helper'

RSpec.describe CarriageSerializer do
  let(:carriage) { create(:carriage) }
  let(:serializer) { described_class.new(carriage) }
  let(:result) { serializer.serializable_hash[:data] }

  describe 'associations' do
    context 'when carriage has seats' do
      let(:carriage) { create(:carriage, :carriage_with_seats) }

      it 'includes seats in result' do
        expect(result[:relationships].keys).to include(:seats)
      end
    end

    context 'when carriage does not has seats' do
      it 'does not include seats in result' do
        expect(result[:relationships].keys).to_not include(:seats)
      end
    end
  end

  describe 'attributes' do
    it 'has attributes name and order number, type is carriage, id is correct' do
      expect(result[:type]).to eq(:carriage)
      expect(result[:id]).to eq(carriage.id.to_s)

      expect(result[:attributes]).to eq({ name: carriage.name, order_number: carriage.order_number })
    end
  end
end
