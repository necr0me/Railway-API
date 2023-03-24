

RSpec.describe Trains::CarriageRemoverService do
  subject(:service) { described_class.call(train: train, carriage_id: carriage.id) }

  let(:train) { create(:train) }
  let(:carriage) { create(:carriage) }

  describe "#call" do
    it "call #remove_carriage method" do
      allow_any_instance_of(described_class).to receive(:remove_carriage).with(no_args)
      service
    end
  end

  describe "#remove_carriage" do
    context "when carriage doesnt exist" do
      let(:carriage) { build(:carriage) }

      it "returns error message" do
        expect(service.error).to eq("Couldn't find Carriage without an ID")
      end
    end

    context "when carriage not in train" do
      it "returns error" do
        expect(service.error).to eq("Can't remove carriage that not in train")
      end
    end

    context "when carriage in different train" do
      let(:carriage) { create(:carriage, train_id: create(:train).id) }

      it "returns error" do
        expect(service.error).to eq("Can't remove carriage from different train")
      end
    end

    context "when carriage in train" do
      let(:train) { create(:train, :train_with_carriages) }
      let(:carriage) { train.carriages.first }

      it "does not contains error and updates data in db" do
        expect(service.error).to be_nil

        expect(carriage.reload.order_number).to be_nil
        expect(carriage.train_id).to be_nil

        expect(carriage.seats.count).to eq(0)

        expect(train.reload.carriages.pluck(:order_number)).to eq((1..train.carriages.count).to_a)
      end
    end
  end

  describe "#decrement_order_numbers_after" do
    let(:train) { create(:train, :train_with_carriages) }
    let(:carriage) { train.carriages.first }

    it "decrements order numbers of carriages after removed carriage in train" do
      service = described_class.new(train: train, carriage_id: carriage.id)
      old_order_numbers = train.carriages.group_by(&:id).except(carriage.id)
      service.send(:decrement_order_numbers_after, carriage)
      new_order_numbers = train.reload.carriages.group_by(&:id).except(carriage.id)
      old_order_numbers.each do |k, v|
        expect(v.first.order_number - new_order_numbers[k].first.order_number).to eq(1)
      end
    end
  end
end
