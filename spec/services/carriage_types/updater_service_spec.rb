RSpec.describe CarriageTypes::UpdaterService do
  let(:carriage_type) { create(:carriage_type) }
  let(:params) do
    {
      name: "Coupe",
      description: "Coupe carriage with 32 seats",
      capacity: 32,
      cost_per_hour: 1.0
    }
  end

  describe "#call" do
    it "calls update method" do
      expect_any_instance_of(described_class).to receive(:update).with(no_args)
      described_class.call(carriage_type: carriage_type,
                           carriage_type_params: params)
    end
  end

  describe "#update" do
    context "when trying to update type with carriages" do
      let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

      it "data is nil, contains error and doesnt updates type" do
        result = described_class.call(carriage_type: carriage_type,
                                      carriage_type_params: params)

        expect(result.data).to be_nil
        expect(result.error[:capacity]).to include("Can't update carriage type capacity that has any carriages")

        expect(carriage_type.name).not_to eq(params[:capacity])
      end
    end

    context "when trying to update type with invalid data" do
      let(:params) do
        {
          name: "x",
          description: "x" * 141,
          capacity: -1,
          cost_per_hour: 1.0
        }
      end

      it "data is nil, contains error and doesnt update type" do
        result = described_class.call(carriage_type: carriage_type,
                                      carriage_type_params: params)

        expect(result.data).to be_nil
        expect(result.error[:capacity]).to include(/must be greater than or equal to 0/)

        expect(carriage_type.reload.name).not_to eq(params[:name])
      end
    end

    context "when trying to update only name and description of type with carriages" do
      let(:carriage_type) { create(:carriage_type, :type_with_carriage) }
      let(:params) do
        {
          name: "Coupe",
          description: "Coupe carriage with 8 seats",
          capacity: carriage_type.capacity,
          cost_per_hour: carriage_type.cost_per_hour
        }
      end

      it "data is updated type, does not contains errors and updates type" do
        result = described_class.call(carriage_type: carriage_type,
                                      carriage_type_params: params)

        expect(result.data.id).to eq(carriage_type.id)
        expect(result.error).to be_nil

        expect(carriage_type.name).to eq(params[:name])
        expect(carriage_type.description).to eq(params[:description])
        expect(carriage_type.capacity).to eq(params[:capacity])
      end
    end

    context "when trying to update type without carriages with valid data" do
      it "data is updated type, does not contains error and updates type" do
        result = described_class.call(carriage_type: carriage_type,
                                      carriage_type_params: params)

        expect(result.data.id).to eq(carriage_type.id)
        expect(result.error).to be_nil

        expect(carriage_type.name).to eq(params[:name])
        expect(carriage_type.description).to eq(params[:description])
        expect(carriage_type.capacity).to eq(params[:capacity])
      end
    end
  end
end
