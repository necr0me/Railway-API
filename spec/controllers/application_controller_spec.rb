RSpec.describe ApplicationController do
  describe "concerns" do
    describe "Authorization" do
      it "includes Authorization concern" do
        expect(described_class.ancestors).to include(Authorization)
      end
    end

    describe "ErrorHandler" do
      it "includes ErrorHandler concern" do
        expect(described_class.ancestors).to include(ErrorHandler)
      end
    end
  end
end
