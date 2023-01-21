require 'rails_helper'

RSpec.describe Train, type: :model do
  let(:train) { create(:train, :train_with_carriages) }

  describe 'associations' do
    context 'route' do
      it 'belongs to route' do
        expect(described_class.reflect_on_association(:route).macro).to eq(:belongs_to)
      end

      it 'route is optional' do
        expect { create(:train) }.to_not raise_error
      end
    end

    context 'carriages' do
      it 'has many carriages' do
        expect(described_class.reflect_on_association(:carriages).macro).to eq(:has_many)
      end

      it 'orders in increasing of order number' do
        train.carriages.pluck(:order_number).each_cons(2) { expect(_2 > _1).to be_truthy }
      end

      it 'nullifies train_id attribute for related carriages' do
        train.destroy
        expect(train.carriages.reload.pluck(:train_id).all?(:nil?)).to be_truthy
      end
    end
  end
end