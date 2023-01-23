require 'rails_helper'

RSpec.describe CarriageTypes::DestroyerService do
  let(:carriage_type) { create(:carriage_type) }

  subject { described_class.call(carriage_type: carriage_type) }

  describe '#call' do
    it 'calls #destroy method' do
      expect_any_instance_of(described_class).to receive(:destroy).with(no_args)
      subject
    end
  end

  describe '#destroy' do
    context 'when error raises during work of service' do
      before do
        allow_any_instance_of(CarriageType).to receive(:destroy!).and_raise('Error message')
      end

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is false' do
        expect(subject.success?).to be_falsey
      end

      it 'contains error message' do
        expect(subject.errors).to include('Error message')
      end

      it 'doesnt delete type from db' do
        subject
        expect { carriage_type.reload }.to_not raise_error
      end
    end

    context 'when trying to destroy type with carriages' do
      let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is false' do
        expect(subject.success?).to be_falsey
      end

      it 'contains error message that cant destroy type with carriages' do
        expect(subject.errors).to include("Can't destroy carriage type that has any carriages")
      end

      it 'doesnt delete type from db' do
        subject
        expect { carriage_type.reload }.to_not raise_error
      end
    end

    context 'when trying to destroy type without carriages' do
      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is true' do
        expect(subject.success?).to be_truthy
      end

      it 'errors value is nil' do
        expect(subject.errors).to be_nil
      end

      it 'deletes type from db' do
        subject
        expect { carriage_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end