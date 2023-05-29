RSpec.describe CarriageTypes::DestroyerService do
  let(:carriage_type) { create(:carriage_type) }

  describe "#call" do
    it "calls #destroy method" do
      expect_any_instance_of(described_class).to receive(:destroy).with(no_args)
      described_class.call(carriage_type: carriage_type)
    end
  end

  describe "#destroy" do
    context "when error raises during work of service" do
      before do
        allow(carriage_type).to receive(:destroy!).and_raise("Some error")
      end

      it " contains error message and does not delete type from db" do
        result = described_class.call(carriage_type: carriage_type)

        expect(result.error).to eq("Some error")
        expect { carriage_type.reload }.not_to raise_error
      end
    end

    context "when trying to destroy type with carriages" do
      let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

      it "contains error message and doesnt delete type from db" do
        result = described_class.call(carriage_type: carriage_type)

        expect(result.error).to eq("Can't destroy carriage type that has any carriages")
        expect { carriage_type.reload }.not_to raise_error
      end
    end

    context "when trying to destroy type without carriages" do
      it "does not contains errors and deletes type from db" do
        result = described_class.call(carriage_type: carriage_type)

        expect(result.error).to be_nil
        expect { carriage_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
