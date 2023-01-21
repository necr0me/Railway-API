require 'rails_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  subject { described_class.new(nil, nil) }

  describe 'policy' do
    it { is_expected.to forbid_actions(%i[index show create new update edit destroy]) }
  end

  describe 'scope' do
    describe '#resolve' do
      let(:resolved_scope) { described_class::Scope.new(nil, nil).resolve }

      it 'raises NotImplementedError' do
        expect { resolved_scope }.to raise_error(NotImplementedError)
      end
    end
  end
end
