RSpec.describe Trains::DestroyerService do
  subject(:service) { described_class.call(train: train) }

  let(:train) { create(:train) }
  let(:carriage) { create(:carriage, train_id: train.id) }

  describe "#destroy" do
    context "when error occurs" do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

      before do
        allow(train).to receive(:destroy).and_return(false)
        allow(train).to receive(:errors).and_return(errors)
      end

      it "success? is false, returns errors" do
        result = service

        expect(result).not_to be_success
        expect(result.error.full_messages).to include("Error message")
      end
    end

    context "when no error occurs" do
      before { create(:seat, carriage_id: carriage.id) }

      it "success? is true, destroys train and seats of carriage" do
        expect(Seat.pluck(:carriage_id)).to include(carriage.id)

        result = service

        expect(result).to be_success
        expect(Seat.pluck(:carriage_id)).not_to include(carriage.id)
      end
    end
  end
end
