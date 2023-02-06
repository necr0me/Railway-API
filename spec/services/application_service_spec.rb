require 'rails_helper'

RSpec.describe ApplicationService do
  let(:service) { described_class.new }

  describe '.call' do
    context 'when no any error occurs' do
      before do
        allow_any_instance_of(described_class).to receive(:call).and_return(nil)
      end

      it 'returns instance, #error is nil' do
        expect { described_class.call }.to_not raise_error
      end
    end

    context 'when error occurs' do
      it 'returns instance, #error contains error message' do
        service = described_class.call
        expect(service.error).to eq('You should define #call first')
      end
    end
  end

  describe '#new' do
    it 'returns new ApplicationService instance' do
      expect(service).to be_kind_of(described_class)
    end
  end

  describe '#call' do
    it 'raises NotImplementedError' do
      expect { service.call }.to raise_error(NotImplementedError)
    end
  end

  describe '#fail' do
    it 'sets error, data is nil' do
      service.send(:fail, error: 'Some error')
      expect(service.error).to eq('Some error')
    end
  end

  describe '#success' do
    it 'sets data, error is nil' do
      service.send(:success, data: 'Some data')
      expect(service.data).to eq('Some data')
    end
  end

  describe '#success?' do
    context 'when no any error occurred' do
      it 'returns true' do
        expect(service.success?).to be_truthy
      end
    end

    context 'when any error occurred' do
      it 'returns false' do
        service.instance_variable_set '@error', 'error'
        expect(service.success?).to be_falsey
      end
    end
  end

  describe 'method alias' do
    it '#fail same as #fail!' do
      expect(service.method(:fail)).to eq(service.method(:fail!))
    end

    it '#success same as #success!' do
      expect(service.method(:success)).to eq(service.method(:success!))
    end
  end
end
