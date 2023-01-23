require 'rails_helper'

RSpec.describe Trains::CarriageRemoverService do
  let(:train) { create(:train) }
  let(:carriage) { create(:carriage) }

  subject { described_class.call(train: train, carriage_id: carriage.id) }

  describe '#call' do
    it 'call #remove_carriage method' do
      allow_any_instance_of(described_class).to receive(:remove_carriage).with(no_args)
      subject
    end
  end

  describe '#remove_carriage' do
    context 'when carriage doesnt exist' do
      let(:carriage) { build(:carriage) }

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is false' do
        expect(subject.success?).to be_falsey
      end

      it 'contains error message that cant find carriage with such id' do
        expect(subject.errors).to include("Couldn't find Carriage without an ID")
      end
    end

    context 'when carriage not in train' do
      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is false' do
        expect(subject.success?).to be_falsey
      end

      it 'contains error that cant remove carriage that not in train' do
        expect(subject.errors).to include("Can't remove carriage that not in train")
      end
    end

    context 'when carriage in different train' do
      let(:carriage) { create(:carriage, train_id: create(:train).id) }

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is false' do
        expect(subject.success?).to be_falsey
      end

      it 'contains error that cant remove carriage from different train' do
        expect(subject.errors).to include("Can't remove carriage from different train")
      end
    end

    context 'when carriage in train' do
      let(:train) { create(:train, :train_with_carriages) }
      let(:carriage) { train.carriages.first }

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is true' do
        expect(subject.success?).to be_truthy
      end

      it 'errors is nil' do
        expect(subject.errors).to be_nil
      end

      it 'nullifies train_id and order_number' do
        subject
        expect(carriage.reload.order_number).to be_nil
        expect(carriage.train_id).to be_nil
      end

      it 'deletes all seats of carriage' do
        subject
        expect(carriage.seats.count).to eq(0)
      end

      it 'decrements order_numbers of carriages that after removed carriage' do
        subject
        expect(train.reload.carriages.pluck(:order_number)).to eq((1..train.carriages.count).to_a)
      end
    end
  end
end