RSpec.describe Seat, type: :model do
  let(:seat) { build(:seat) }

  describe "associations" do
    describe "carriage" do
      it "belongs to carriage" do
        expect(described_class.reflect_on_association(:carriage).macro).to eq(:belongs_to)
      end
    end

    describe "ticket" do
      let(:seat) { create(:seat, :seat_with_ticket) }

      it "has one ticket" do
        expect(described_class.reflect_on_association(:ticket).macro).to eq(:has_one)
      end

      it "deletes ticket with seat" do
        seat.destroy
        expect { seat.ticket.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "scopes", long: true do
    before { create_list(:seat, 10) }

    it "by default sorts according to increasing #number" do
      described_class.all.pluck(:number).each_cons(2) { expect(_1 <= _2).to be_truthy }
    end
  end

  describe "validations" do
    describe "#number" do
      context "when number < 1 or blank" do
        it "is invalid" do
          seat.number = nil
          expect(seat).not_to be_valid

          seat.number = 0
          expect(seat).not_to be_valid
        end
      end

      context "when number >= 1" do
        it "is valid" do
          seat.number = 1
          expect(seat).to be_valid

          seat.number = 10
          expect(seat).to be_valid
        end
      end
    end
  end
end
