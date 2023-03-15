require 'rails_helper'

RSpec.describe StationPolicy, type: :policy do
  let(:station) { create(:station) }

  subject { described_class.new(user, station) }

  context 'being visitor' do
    let(:user) { nil }

    it { is_expected.to permit_actions(%i[index show]) }

    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context 'being user' do
    let(:user) { create(:user) }

    it { is_expected.to permit_actions(%i[index show]) }

    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context 'being moderator' do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to permit_actions(%i[index show create update destroy]) }
  end

  context 'being admin' do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_actions(%i[index show create update destroy]) }
  end
end

