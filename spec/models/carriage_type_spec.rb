RSpec.describe CarriageType, type: :model do
  let(:carriage_type) { build(:carriage_type) }

  describe "associations" do
    let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

    describe "Carriage" do
      it "has many carriages" do
        expect(described_class.reflect_on_association(:carriages).macro).to eq(:has_many)
      end

      it "raises exception when trying to destroy type with carriages" do
        expect { carriage_type.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
      end
    end
  end

  describe "auto_strip_attributes" do
    describe "#name" do
      it "removes redundant whitespaces" do
        carriage_type.name = "\s\s\sName\s\s\sWith\s\s\s\sWhitespaces\s\s\s\s"
        carriage_type.save
        expect(carriage_type.name.count(" ")).to eq(2)
      end

      it "removes redundant validations at the start and at the end" do
        carriage_type.name = "\t\t\tName\t\t\tWith\t\t\tTabulations\t\t"
        carriage_type.save
        expect(carriage_type.name.count(" ")).to eq(2)
      end
    end

    describe "#description" do
      it "removes redundant whitespaces" do
        carriage_type.description = "\s\s\sDescription\s\s\sWith\s\s\sWhitespaces\s\s\s"
        carriage_type.save
        expect(carriage_type.description.count(" ")).to eq(2)
      end

      it "removes redundant validations at the start and at the end" do
        carriage_type.description = "Description\t\t\tWith\t\t\tTabulations\t\t\t"
        carriage_type.save
        expect(carriage_type.description.count(" ")).to eq(2)
      end
    end
  end

  describe "validations" do
    describe "#name" do
      context "when name is blank" do
        it "is invalid" do
          carriage_type.name = ""
          expect(carriage_type).not_to be_valid
          expect(carriage_type.errors[:name]).to include(/can't be blank/)
        end
      end

      context "when name is too short (less than 3 characters)" do
        it "is invalid" do
          carriage_type.name = "x"
          expect(carriage_type).not_to be_valid
          expect(carriage_type.errors[:name]).to include(/too short/)
        end
      end

      context "when name is too long (more than 32 characters)" do
        it "is invalid" do
          carriage_type.name = "x" * 33
          expect(carriage_type).not_to be_valid
          expect(carriage_type.errors[:name]).to include(/too long/)
        end
      end
    end

    describe "#description" do
      context "when description is too long (more than 140 characters)" do
        it "is invalid" do
          carriage_type.description = "x" * 141
          expect(carriage_type).not_to be_valid
          expect(carriage_type.errors[:description]).to include(/too long/)
        end
      end
    end

    describe "#capacity" do
      context "when capacity is blank" do
        it "is invalid" do
          carriage_type.capacity = nil
          expect(carriage_type).not_to be_valid
          expect(carriage_type.errors[:capacity]).to include(/can't be blank/)
        end
      end

      context "when capacity is negative number" do
        it "is invalid" do
          carriage_type.capacity = -1
          expect(carriage_type).not_to be_valid
          expect(carriage_type.errors[:capacity]).to include("must be greater than or equal to 0")
        end
      end
    end

    describe "#cost_per_hour" do
      context "when cost_per_hour is blank" do
        let(:carriage_type) { build(:carriage_type, cost_per_hour: nil) }

        it "is invalid" do
          expect(carriage_type).not_to be_valid
        end
      end

      context "when cost_per_hour is less than 0" do
        let(:carriage_type) { build(:carriage_type, cost_per_hour: -1) }

        it "is invalid" do
          expect(carriage_type).not_to be_valid
        end
      end

      context "when cost_per_hour bigger than 0" do
        let(:carriage_type) { build(:carriage_type, cost_per_hour: 0.1) }

        it "is valid" do
          expect(carriage_type).to be_valid
        end
      end
    end
  end
end
