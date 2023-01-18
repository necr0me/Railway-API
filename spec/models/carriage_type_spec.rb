require 'rails_helper'

RSpec.describe CarriageType, type: :model do
  let(:carriage_type) { build(:carriage_type) }

  describe 'associations' do
    context 'Carriage' do
      it 'has many carriages' do
        expect(described_class.reflect_on_association(:carriages).macro).to eq(:has_many)
      end
    end
  end

  describe 'auto_strip_attributes' do
    context '#name' do
      it 'removes redundant whitespaces' do
        carriage_type.name = "\s\s\sName\s\s\sWith\s\s\s\sWhitespaces\s\s\s\s"
        carriage_type.save
        expect(carriage_type.name.count(' ')).to eq(2)
      end

      it 'removes redundant validations at the start and at the end' do
        carriage_type.name = "\t\t\tName\t\t\tWith\t\t\tTabulations\t\t"
        carriage_type.save
        expect(carriage_type.name.count(' ')).to eq(2)
      end
    end

    context '#description' do
      it 'removes redundant whitespaces' do
        carriage_type.description = "\s\s\sDescription\s\s\sWith\s\s\sWhitespaces\s\s\s"
        carriage_type.save
        expect(carriage_type.description.count(' ')).to eq(2)
      end

      it 'removes redundant validations at the start and at the end' do
        carriage_type.description = "Description\t\t\tWith\t\t\tTabulations\t\t\t"
        carriage_type.save
        expect(carriage_type.description.count(' ')).to eq(2)
      end
    end
  end

  describe 'validations' do
    context '#name' do
      it 'is invalid when name is blank' do
        carriage_type.name = ''
        expect(carriage_type).to_not be_valid
        expect(carriage_type.errors[:name]).to include(/can't be blank/)
      end

      it 'is invalid when name is too short (3-)' do
        carriage_type.name = 'x'
        expect(carriage_type).to_not be_valid
        expect(carriage_type.errors[:name]).to include(/too short/)
      end

      it 'is invalid when name is too long (32+)' do
        carriage_type.name = 'x' * 33
        expect(carriage_type).to_not be_valid
        expect(carriage_type.errors[:name]).to include(/too long/)
      end
    end

    context '#description' do
      it 'is invalid when description is too long (140+)' do
        carriage_type.description = 'x' * 141
        expect(carriage_type).to_not be_valid
        expect(carriage_type.errors[:description]).to include(/too long/)
      end
    end

    context '#capacity' do
      it 'is invalid when capacity is blank' do
        carriage_type.capacity = nil
        expect(carriage_type).to_not be_valid
        expect(carriage_type.errors[:capacity]).to include(/can't be blank/)
      end

      it 'is invalid when capacity is invalid' do
        carriage_type.capacity = -1
        expect(carriage_type).to_not be_valid
        expect(carriage_type.errors[:capacity]).to include('must be greater than or equal to 0')
      end
    end
  end
end
