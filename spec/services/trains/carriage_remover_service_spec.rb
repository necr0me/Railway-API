require 'rails_helper'

RSpec.describe Trains::CarriageRemoverService do
  let(:train) { create(:train) }
  let(:carriage) { create(:carriage) }

  describe '#call' do
    it 'call #remove_carriage method' do
      allow_any_instance_of(described_class).to receive(:remove_carriage).with(no_args)
      described_class.call(train: train, carriage_id: carriage.id)
    end
  end

  describe '#remove_carriage' do
    context 'when carriage doesnt exist' do
      let(:carriage) { build(:carriage) }

      it 'returns OpenStruct object, success? is false and contains error message' do
        result = described_class.call(train: train, carriage_id: carriage.id)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_falsey

        expect(result.errors).to include("Couldn't find Carriage without an ID")
      end
    end

    context 'when carriage not in train' do
      it 'returns OpenStruct object, success? is false and contains error' do
        result = described_class.call(train: train, carriage_id: carriage.id)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_falsey

        expect(result.errors).to include("Can't remove carriage that not in train")
      end
    end

    context 'when carriage in different train' do
      let(:carriage) { create(:carriage, train_id: create(:train).id) }

      it 'returns OpenStruct object, success? is false and contains error' do
        result = described_class.call(train: train, carriage_id: carriage.id)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_falsey

        expect(result.errors).to include("Can't remove carriage from different train")
      end
    end

    context 'when carriage in train' do
      let(:train) { create(:train, :train_with_carriages) }
      let(:carriage) { train.carriages.first }

      it 'returns OpenStruct object, success? is true, no errors and updates data in db' do
        result = described_class.call(train: train, carriage_id: carriage.id)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_truthy

        expect(result.errors).to be_nil

        expect(carriage.reload.order_number).to be_nil
        expect(carriage.train_id).to be_nil

        expect(carriage.seats.count).to eq(0)

        expect(train.reload.carriages.pluck(:order_number)).to eq((1..train.carriages.count).to_a)
      end
    end
  end
end