require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject { described_class.new(user, resource_user) }

  let(:resource_user) { create(:user) }

  context 'being visitor' do
    let(:user) { nil }

    it { is_expected.to permit_actions(%i[create]) }

    it { is_expected.to forbid_actions(%i[show update destroy]) }
  end

  context 'being user' do
    context 'being correct user' do
      let(:user) { resource_user }

      it { is_expected.to permit_actions(%i[show update destroy]) }

      it { is_expected.to forbid_actions(%i[create]) }
    end

    context 'being other user' do
      let(:user) { create(:user, email: 'mail@gmail.com', password: 'password') }

      it { is_expected.to forbid_actions(%i[create show update destroy]) }
    end
  end

  context 'being moderator' do
    let(:user) { create(:user, email: 'mail@gmail.com', password: 'password', role: 1) }

    context 'own resources' do
      let(:resource_user) { user }

      it { is_expected.to permit_actions(%i[show update destroy]) }

      it { is_expected.to forbid_actions(%i[create]) }
    end

    context 'other users resources' do
      it { is_expected.to permit_action(:show) }

      it { is_expected.to forbid_actions(%i[create update destroy]) }
    end

  end

  context 'being admin' do
    let(:user) { create(:user, email: 'mail@gmail.com', password: 'password', role: 2) }

    context 'own resources' do
      let(:resource_user) { user }

      it { is_expected.to permit_actions(%i[show update destroy]) }

      it { is_expected.to forbid_actions(%i[create]) }
    end

    context 'other resources' do
      it { is_expected.to permit_actions(%i[show destroy]) }

      it { is_expected.to forbid_actions(%i[update create]) }
    end
  end
end
