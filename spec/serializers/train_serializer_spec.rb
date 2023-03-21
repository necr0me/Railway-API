require 'rails_helper'

RSpec.describe TrainSerializer do
  let(:train) { create(:train) }
  let(:serializer) { described_class.new(train) }
  let(:result) { serializer.serializable_hash[:data] }

  describe 'attributes' do
    it 'type is train, id is correct' do
      expect(result[:type]).to eq(:train)
      expect(result[:id]).to eq(train.id.to_s)
    end
  end
end
