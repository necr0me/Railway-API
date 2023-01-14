require 'rails_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  subject { described_class.new(nil, nil) }

  describe 'policy' do
    it 'forbids to #index' do
      expect(subject).to forbid_action(:index)
    end

    it 'forbids to #show' do
      expect(subject).to forbid_action(:show)
    end

    it 'forbids to #create' do
      expect(subject).to forbid_action(:create)
    end

    it 'forbids to #new' do
      expect(subject).to forbid_action(:new)
    end

    it 'forbids to #update' do
      expect(subject).to forbid_action(:update)
    end

    it 'forbids to #edit' do
      expect(subject).to forbid_action(:edit)
    end

    it 'forbids to #destroy' do
      expect(subject).to forbid_action(:destroy)
    end
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
