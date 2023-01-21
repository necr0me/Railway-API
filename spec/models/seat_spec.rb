require 'rails_helper'

RSpec.describe Seat, type: :model do
  describe 'associations' do
    context 'Carriage' do
      it 'belongs to carriage' do
        expect(described_class.reflect_on_association(:carriage).macro).to eq(:belongs_to)
      end
    end
  end
end
