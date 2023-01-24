require 'rails_helper'

RSpec.describe Trains::CarriageAdderService do
  let(:train) { create(:train) }
  let(:carriage) { create(:carriage) }

  describe '#call' do
    it 'calls #add_carriage method' do
      allow_any_instance_of(described_class).to receive(:add_carriage).with(no_args)
      described_class.call(train: train, carriage_id: carriage.id)
    end
  end

  describe '#add_carriage' do
    context 'when carriage doesnt exist' do
      let(:carriage) { build(:carriage) }

      it 'returns OpenStruct object, success? is false, data is nil, contains error message' do
        result = described_class.call(train: train, carriage_id: carriage.id)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_falsey

        expect(result.data).to be_nil

        expect(result.errors).to include("Couldn't find Carriage without an ID")
      end
    end

    context 'when carriage already in train' do
      let(:carriage) { create(:carriage, train_id: train.id) }

      it 'returns OpenStruct object, success? is false, data is nil, contains error message' do
        result = described_class.call(train: train, carriage_id: carriage.id)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_falsey

        expect(result.data).to be_nil

        expect(result.errors).to include('Carriage already in train')
      end
    end

    context 'when carriage exist and not in train' do
      it 'returns OpenStruct object, success? is true, data is added carriage, no errors and updates record in db' do
        result = described_class.call(train: train, carriage_id: carriage.id)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_truthy

        expect(result.data).to eq(carriage)

        expect(result.errors).to be_nil

        expect(carriage.seats.count).to eq(carriage.capacity)

        expect(carriage.reload.train_id).to eq(train.id)
        expect(carriage.order_number).to eq(train.carriages.count)
      end
    end
  end
end