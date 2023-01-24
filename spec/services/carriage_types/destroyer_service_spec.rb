require 'rails_helper'

RSpec.describe CarriageTypes::DestroyerService do
  let(:carriage_type) { create(:carriage_type) }

  describe '#call' do
    it 'calls #destroy method' do
      expect_any_instance_of(described_class).to receive(:destroy).with(no_args)
      described_class.call(carriage_type: carriage_type)
    end
  end

  describe '#destroy' do
    context 'when error raises during work of service' do
      before do
        allow_any_instance_of(CarriageType).to receive(:destroy!).and_raise('Error message')
      end

      it 'returns OpenStruct object, success? is false, contains error message and does not delete type from db' do
        result = described_class.call(carriage_type: carriage_type)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_falsey

        expect(result.errors).to include('Error message')

        expect { carriage_type.reload }.to_not raise_error
      end
    end

    context 'when trying to destroy type with carriages' do
      let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

      it 'returns OpenStruct object, success? is false, contains error message and doesnt delete type from db' do
        result = described_class.call(carriage_type: carriage_type)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_falsey

        expect(result.errors).to include("Can't destroy carriage type that has any carriages")

        expect { carriage_type.reload }.to_not raise_error
      end
    end

    context 'when trying to destroy type without carriages' do
      it 'returns OpenStruct object, success? is false, contains no errors and deletes type from db' do
        result = described_class.call(carriage_type: carriage_type)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_truthy

        expect(result.errors).to be_nil

        expect { carriage_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end