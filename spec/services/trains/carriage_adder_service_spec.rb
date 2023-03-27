RSpec.describe Trains::CarriageAdderService do
  subject(:service) { described_class.call(train: train, carriage_id: carriage.id) }

  let(:train) { create(:train) }
  let(:carriage) { create(:carriage) }

  describe "#call" do
    it "calls #add_carriage method" do
      allow_any_instance_of(described_class).to receive(:add_carriage).with(no_args)
      service
    end
  end

  describe "#add_carriage" do
    context "when carriage doesnt exist" do
      let(:carriage) { build(:carriage) }

      it "data is nil, contains error message" do
        expect(service.data).to be_nil
        expect(service.error).to eq("Couldn't find Carriage without an ID")
      end
    end

    context "when carriage already in train" do
      let(:carriage) { create(:carriage, train_id: train.id) }

      it "data is nil, contains error message" do
        expect(service.data).to be_nil
        expect(service.error).to eq("Carriage already in train")
      end
    end

    context "when carriage exist and not in train" do
      it "data is added carriage, does not contains error and updates record in db" do
        expect(service.data).to eq(carriage)
        expect(service.error).to be_nil

        expect(carriage.seats.count).to eq(carriage.capacity)

        expect(carriage.reload.train_id).to eq(train.id)
        expect(carriage.order_number).to eq(train.carriages.count)
      end
    end
  end

  describe "#create_seats_for" do
    it "creates seats for carriage" do
      service = described_class.new(train: train, carriage_id: carriage.id)
      service.send(:create_seats_for, carriage)
      expect(carriage.reload.capacity).to eq(carriage.seats.count)
    end
  end
end
