require 'rails_helper'

RSpec.describe TicketPolicy, type: :policy do
  let(:ticket) { create(:ticket, user: user) }

  subject { described_class.new(user, ticket) }

  context 'being a visitor' do
    let(:user) { nil }

    subject { described_class.new(user, create(:ticket)) }

    it { is_expected.to forbid_actions(%i[show create destroy]) }
  end

  context 'being a user' do
    let(:user) { create(:user) }

    context 'being correct user (user is owner of ticket)' do
      it { is_expected.to permit_actions(%i[show create destroy]) }
    end

    context 'being incorrect user (user is not owner of ticket)' do
      let(:ticket) { create(:ticket, user: create(:user, email: 'm@mail.com')) } # TODO: remove email after factory fix

      it { is_expected.to permit_actions(%i[create]) }

      it { is_expected.to forbid_actions(%i[show destroy]) }
    end
  end

  context 'being moderator' do
    let(:user) { create(:user, role: :moderator) }
    let(:ticket) { create(:ticket, user: create(:user, email: 'm@mail.com')) }

    it { is_expected.to permit_actions(%i[show create]) }

    it { is_expected.to forbid_actions(%i[destroy]) }
  end

  context 'being admin' do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_actions(%i[show create destroy]) }
  end
end
