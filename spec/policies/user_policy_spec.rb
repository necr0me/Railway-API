require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject { described_class.new(user, resource_user) }

  let(:resource_user) { create(:user) }

  context 'being visitor' do
    let(:user) { nil }

    it 'forbids to #show' do
      expect(subject).to forbid_action(:show)
    end

    it 'forbids to #update' do
      expect(subject).to forbid_action(:update)
    end

    it 'forbids to #destroy' do
      expect(subject).to forbid_action(:destroy)
    end
  end

  context 'being user' do
    context 'being correct user' do
      let(:user) { resource_user }

      it 'permits to #show' do
        expect(subject).to permit_action(:show)
      end

      it 'permits to #update' do
        expect(subject).to permit_action(:update)
      end

      it 'permits to #destroy' do
        expect(subject).to permit_action(:destroy)
      end
    end

    context 'being other user' do
      let(:user) { create(:user, email: 'mail@gmail.com', password: 'password') }

      it 'forbids to #show' do
        expect(subject).to forbid_action(:show)
      end

      it 'forbids to #update' do
        expect(subject).to forbid_action(:update)
      end

      it 'forbids to #destroy' do
        expect(subject).to forbid_action(:destroy)
      end
    end
  end

  context 'being moderator' do
    let(:user) { create(:user, email: 'mail@gmail.com', password: 'password', role: 1) }

    context 'own resources' do
      let(:resource_user) { user }

      it 'permits to #show' do
        expect(subject).to permit_action(:show)
      end

      it 'permits to #update' do
        expect(subject).to permit_action(:update)
      end

      it 'permits to #destroy' do
        expect(subject).to permit_action(:destroy)
      end
    end

    context 'other users resources' do
      it 'permits to #show' do
        expect(subject).to permit_action(:show)
      end

      it 'forbids to #update' do
        expect(subject).to forbid_action(:update)
      end

      it 'forbids to #destroy' do
        expect(subject).to forbid_action(:destroy)
      end
    end

  end

  context 'being admin' do
    let(:user) { create(:user, email: 'mail@gmail.com', password: 'password', role: 2) }

    context 'own resources' do
      let(:resource_user) { user }

      it 'permits to #show' do
        expect(subject).to permit_action(:show)
      end

      it 'permits to #update' do
        expect(subject).to permit_action(:update)
      end

      it 'permits to #destroy' do
        expect(subject).to permit_action(:destroy)
      end
    end

    context 'other resources' do
      it 'permits to #show' do
        expect(subject).to permit_action(:show)
      end

      it 'forbids to #update' do
        expect(subject).to forbid_action(:update)
      end

      it 'permits to #destroy' do
        expect(subject).to permit_action(:destroy)
      end
    end
  end
end
