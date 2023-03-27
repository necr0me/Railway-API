RSpec.describe Train, type: :model do
  let(:train) { create(:train, :train_with_carriages) }

  describe "associations" do
    describe "route" do
      it "belongs to route" do
        expect(described_class.reflect_on_association(:route).macro).to eq(:belongs_to)
      end

      it "route is optional" do
        expect { create(:train) }.not_to raise_error
      end
    end

    describe "carriages" do
      it "has many carriages" do
        expect(described_class.reflect_on_association(:carriages).macro).to eq(:has_many)
      end

      it "nullifies train_id attribute for related carriages" do
        train.destroy
        expect(train.carriages.reload.pluck(:train_id)).to be_all(:nil?)
      end
    end

    describe "stops" do
      let(:train) { create(:train, :train_with_stops) }

      it "has many stops" do
        expect(described_class.reflect_on_association(:stops).macro).to eq(:has_many)
      end

      it "destroys with train" do
        expect { train.destroy }.to change { train.stops.size }.from(3).to(0)
      end
    end
  end

  describe "callbacks" do
    describe "#before_destroy" do
      it "sets order_number to nil for all relevant carriages" do
        carriages = train.carriages
        train.destroy
        expect(carriages.reload.pluck(:order_number)).to be_all(:nil?)
      end
    end
  end
end
