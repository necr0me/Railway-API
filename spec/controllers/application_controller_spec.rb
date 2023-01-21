require 'rails_helper'

RSpec.describe ApplicationController do
  describe 'concerns' do
    context 'Authorization' do
      it 'includes Authorization concern' do
        expect(described_class.ancestors).to include(Authorization)
      end
    end

    context 'ErrorHandler' do
      it 'includes ErrorHandler concern' do
        expect(described_class.ancestors).to include(ErrorHandler)
      end
    end
  end
end