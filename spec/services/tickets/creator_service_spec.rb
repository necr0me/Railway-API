require 'rails_helper'

RSpec.describe Tickets::CreatorService do
  let(:user) { create(:user) }
  let(:seat) { create(:seat) }
  let(:station) { create(:station) }
  let(:price) { 1 }

  let(:ticket_params) do
    {
      user_id: user.id,
      seat_id: seat.id,
      departure_station_id: station.id,
      arrival_station_id: station.id,
      price: price
    }
  end

  subject { described_class.call(ticket_params: ticket_params) }

  describe '#call' do
    it 'it calls create_ticket method' do
      expect_any_instance_of(described_class).to receive(:create_ticket).with(no_args)
      subject
    end
  end

  describe '#create_ticket' do
    context 'when seat is taken' do
      let(:seat) { create(:seat, is_taken: true) }

      it 'does not create ticket, data is nil and contains error that seat is already taken' do
        result = subject

        expect(result.data).to be_nil
        expect(result.error).to eq('Seat is already taken')
        expect { Ticket.find_by!(seat_id: seat.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when seat is not taken, but error occurs during ticket create' do
      let(:price) { nil }

      it 'does not create ticket, data is nil and contains error' do
        result = subject

        expect(result.data).to be_nil
        expect(result.error).to_not be_nil
        expect { Ticket.find_by!(seat_id: seat.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when seat is not taken and no error occurs during ticket create' do
      it 'it creates ticket, data is created ticket and error is nil' do
        result = subject

        expect(result.data).to_not be_nil
        expect(result.error).to be_nil
        expect(result.data.id).to eq(Ticket.last.id)
      end
    end
  end
end