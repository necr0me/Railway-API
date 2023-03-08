require 'rails_helper'

describe PassingTrainPolicy, type: :policy do
  subject { described_class.new(user, create(:passing_train)) }

  context 'being visitor' do
    let(:user) { nil }

    it { is_expected.to permit_actions(%i[index]) }

    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context 'being user' do
    let(:user) { create(:user) }

    it { is_expected.to permit_actions(%i[index]) }

    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context 'being moderator' do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to permit_actions(%i[index create update destroy]) }
  end

  context 'being admin' do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_actions(%i[index create update destroy]) }
  end
end