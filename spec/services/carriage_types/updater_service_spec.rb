require 'rails_helper'

RSpec.describe CarriageTypes::UpdaterService do
  let(:carriage_type) { create(:carriage_type) }
  let(:params) { {
    name: 'Coupe',
    description: 'Coupe carriage with 32 seats',
    capacity: 32
  } }

  describe '#call' do
    it 'calls update method' do
      expect_any_instance_of(described_class).to receive(:update).with(no_args)
      described_class.call(carriage_type: carriage_type,
                           carriage_type_params: params)
    end
  end

  describe '#update' do
    context 'when trying to update type with carriages' do
      let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

      it 'returns OpenStruct object, success? is false, data is nil, contains error and doesnt updates type' do
        result = described_class.call(carriage_type: carriage_type,
                                      carriage_type_params: params)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_falsey

        expect(result.data).to be_nil

        expect(result.errors).to include("Can't update carriage type capacity that has any carriages")

        expect(carriage_type.name).to_not eq(params[:capacity])
      end
    end

    context 'when trying to update type with invalid data' do
      let(:params) { {
        name: 'x',
        description: 'x' * 141,
        capacity: -1
      } }

      it 'returns OpenStruct object, success? is false, data is nil, contains error and doesnt update type' do
        result = described_class.call(carriage_type: carriage_type,
                                      carriage_type_params: params)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_falsey

        expect(result.data).to be_nil

        expect(result.errors).to include(/Validation failed/)

        expect(carriage_type.reload.name).to_not eq(params[:name])
      end
    end

    context 'when trying to update only name and description of type with carriages' do
      let(:carriage_type) { create(:carriage_type, :type_with_carriage) }
      let(:params) { {
        name: 'Coupe',
        description: 'Coupe carriage with 8 seats',
        capacity: carriage_type.capacity
      } }

      it 'returns OpenStruct object, success? is true, data is updated type, no errors and updates type' do
        result = described_class.call(carriage_type: carriage_type,
                                      carriage_type_params: params)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_truthy

        expect(result.data.id).to eq(carriage_type.id)

        expect(result.errors).to be_nil

        expect(carriage_type.name).to eq(params[:name])
        expect(carriage_type.description).to eq(params[:description])
        expect(carriage_type.capacity).to eq(params[:capacity])
      end
    end

    context 'when trying to update type without carriages with valid data' do
      it 'returns OpenStruct object, success? is true, data is updated type, no errors and updates type' do
        result = described_class.call(carriage_type: carriage_type,
                                      carriage_type_params: params)

        expect(result).to be_kind_of(OpenStruct)

        expect(result.success?).to be_truthy

        expect(result.data.id).to eq(carriage_type.id)

        expect(result.errors).to be_nil

        expect(carriage_type.name).to eq(params[:name])
        expect(carriage_type.description).to eq(params[:description])
        expect(carriage_type.capacity).to eq(params[:capacity])
      end
    end
  end
end