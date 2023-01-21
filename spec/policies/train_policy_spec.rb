require 'rails_helper'

RSpec.describe TrainPolicy, type: :policy do
  subject { described_class.new(user, create(:train)) }

  context 'being visitor' do
    let(:user) { nil }

    it { is_expected.to forbid_actions(%i[index show create update add_carriage remove_carriage destroy]) }
  end

  context 'being user' do
    let(:user) { create(:user) }

    it { is_expected.to forbid_actions(%i[index show create update add_carriage remove_carriage destroy]) }
  end

  context 'being moderator' do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to permit_actions(%i[index show create update add_carriage remove_carriage destroy]) }
  end

  context 'being admin' do
    let(:user) { create(:user, role: :admin)}

    it { is_expected.to permit_actions(%i[index show create update add_carriage remove_carriage destroy]) }
  end
end