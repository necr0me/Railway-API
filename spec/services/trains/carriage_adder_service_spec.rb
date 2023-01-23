require 'rails_helper'

RSpec.describe Trains::CarriageAdderService do
  let(:train) { create(:train) }
  let(:carriage) { create(:carriage) }

  subject { described_class.call(train: train, carriage_id: carriage.id) }

  describe '#call' do
    it 'calls #add_carriage method' do
      allow_any_instance_of(described_class).to receive(:add_carriage).with(no_args)
      subject
    end
  end

  describe '#add_carriage' do
    context 'when carriage doesnt exist' do
      let(:carriage) { build(:carriage) }

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is false' do
        expect(subject.success?).to be_falsey
      end

      it 'data is nil' do
        expect(subject.data).to be_nil
      end

      it 'contains error message that couldnt find carriage without an id' do
        expect(subject.errors).to include("Couldn't find Carriage without an ID")
      end
    end

    context 'when carriage already in train' do
      let(:carriage) { create(:carriage, train_id: train.id) }

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is false' do
        expect(subject.success?).to be_falsey
      end

      it 'data is nil' do
        expect(subject.data).to be_nil
      end

      it 'contains error message that carriage already in train' do
        expect(subject.errors).to include('Carriage already in train')
      end
    end

    context 'when carriage exist and not in train' do
      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is true' do
        expect(subject.success?).to be_truthy
      end

      it 'data contains added carriage' do
        expect(subject.data).to eq(carriage)
      end

      it 'errors is nil' do
        expect(subject.errors).to be_nil
      end

      it 'creates seats for carriage' do
        subject
        expect(carriage.seats.count).to eq(carriage.capacity)
      end

      it 'sets train id to train#id and correct order number' do
        subject
        expect(carriage.reload.train_id).to eq(train.id)
        expect(carriage.order_number).to eq(train.carriages.count)
      end
    end
  end
end