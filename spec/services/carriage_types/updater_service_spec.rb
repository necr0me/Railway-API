require 'rails_helper'

RSpec.describe CarriageTypes::UpdaterService do
  let(:carriage_type) { create(:carriage_type) }
  let(:params) { {
    name: 'Coupe',
    description: 'Coupe carriage with 32 seats',
    capacity: 32
  } }

  subject { described_class.call(carriage_type: carriage_type,
                                 carriage_type_params: params) }

  describe '#call' do
    it 'calls update method' do
      expect_any_instance_of(described_class).to receive(:update).with(no_args)
      subject
    end
  end

  describe '#update' do
    context 'when trying to update type with carriages' do
      let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is false' do
        expect(subject.success?).to be_falsey
      end

      it 'data value is nil' do
        expect(subject.data).to be_nil
      end

      it 'contains error message that cant update type that has carriages' do
        expect(subject.errors).to include("Can't update carriage type capacity that has any carriages")
      end

      it 'doesnt updates type data in db' do
        subject
        expect(carriage_type.name).to_not eq(params[:capacity])
      end
    end

    context 'when trying to update type with invalid data' do
      let(:params) { {
        name: 'x',
        description: 'x' * 141,
        capacity: -1
      } }

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is false' do
        expect(subject.success?).to be_falsey
      end

      it 'data value is nil' do
        expect(subject.data).to be_nil
      end

      it 'contains error message with failed validations' do
        expect(subject.errors).to include(/Validation failed/)
      end

      it 'doesnt updates type data in db' do
        subject
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

      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is true' do
        expect(subject.success?).to be_truthy
      end

      it 'data value is updated type' do
        expect(subject.data.id).to eq(carriage_type.id)
      end

      it 'errors is nil' do
        expect(subject.errors).to be_nil
      end

      it 'updates type data in db' do
        subject
        expect(carriage_type.name).to eq(params[:name])
        expect(carriage_type.description).to eq(params[:description])
        expect(carriage_type.capacity).to eq(params[:capacity])
      end
    end

    context 'when trying to update type without carriages with valid data' do
      it 'returns OpenStruct object' do
        expect(subject).to be_kind_of(OpenStruct)
      end

      it 'success? value is true' do
        expect(subject.success?).to be_truthy
      end

      it 'data value is updated type' do
        expect(subject.data.id).to eq(carriage_type.id)
      end

      it 'errors is nil' do
        expect(subject.errors).to be_nil
      end

      it 'updates type data in db' do
        subject
        expect(carriage_type.name).to eq(params[:name])
        expect(carriage_type.description).to eq(params[:description])
        expect(carriage_type.capacity).to eq(params[:capacity])
      end
    end
  end
end