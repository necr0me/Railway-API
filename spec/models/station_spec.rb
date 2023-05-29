RSpec.describe Station, type: :model do
  let(:station) { create(:station) }
  let(:invalid_station) { build(:station, name: " ") }
  let(:station_in_route) { create(:station, :station_with_route) }

  describe "associations" do
    describe "routes" do
      it "has many routes" do
        expect(described_class.reflect_on_association(:routes).macro).to eq(:has_many)
      end
    end

    describe "station_order_numbers" do
      it "has many station order numbers" do
        expect(described_class.reflect_on_association(:station_order_numbers).macro).to eq(:has_many)
      end

      it "destroys with station" do
        route_id = station_in_route.routes.first.id
        station_id = station_in_route.id
        station_in_route.destroy
        expect do
          StationOrderNumber.find_by!(route_id: route_id, station_id: station_id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "passing_trains" do
      let(:station) { create(:station, :station_with_train_stops) }

      it "has many passing trains" do
        expect(described_class.reflect_on_association(:train_stops).macro).to eq(:has_many)
      end

      it "destroys with station" do
        expect { station.destroy }.to change { station.train_stops.size }.from(3).to(0)
      end
    end

    describe "trains" do
      it "has many trains" do
        expect(described_class.reflect_on_association(:train_stops).macro).to eq(:has_many)
      end
    end
  end

  describe "auto_strip_attributes" do
    describe "#name" do
      it "removes redundant whitespaces at start and at the end" do
        invalid_station.name = "\s\s\sName With Whitespaces\s\s\s"
        invalid_station.save
        expect(invalid_station.name.count(" ")).to eq(2)
      end

      it "removes tabulations" do
        invalid_station.name = "Name\t\t\tWith\t\t\tTabulations"
        invalid_station.save
        expect(invalid_station.name.count(" ")).to eq(2)
      end
    end
  end

  describe "validations" do
    describe "#name" do
      context "when name is blank" do
        it "is invalid" do
          expect(invalid_station).not_to be_valid
          expect(invalid_station.errors[:name]).to include("can't be blank")
        end
      end

      context "when name is too short (less than 2 characters)" do
        it "is invalid" do
          invalid_station.name = "x"
          expect(invalid_station).not_to be_valid
          expect(invalid_station.errors[:name]).to include(/too short/)
        end
      end

      context "when name is too long (more than 50 characters)" do
        it "is invalid" do
          invalid_station.name = "x" * 51
          expect(invalid_station).not_to be_valid
          expect(invalid_station.errors[:name]).to include(/too long/)
        end
      end

      context "when name is not unique" do
        it "is invalid" do
          invalid_station.name = station.name
          expect(invalid_station).not_to be_valid
          expect(invalid_station.errors[:name]).to include("has already been taken")
        end
      end

      context "when name is not blank, unique, length is correct" do
        it "is valid" do
          expect(station).to be_valid
        end
      end
    end

    describe "#number_of_ways" do
      context "when number of ways is blank" do
        it "is invalid" do
          station.number_of_ways = nil
          expect(station).not_to be_valid
        end
      end

      context "when number of ways is 0 or less" do
        it "is invalid" do
          station.number_of_ways = 0
          expect(station).not_to be_valid
        end
      end

      context "when number of ways greater than 0" do
        it "is valid" do
          station.number_of_ways = 1
          expect(station).to be_valid
        end
      end
    end
  end
end
