RSpec.describe Users::TokenGeneratorService do
  subject(:token) { described_class.call.data }

  describe "#generate_token" do
    it "generates hex 32 chars long token" do
      expect(token.size).to eq(32)
      expect(token).to match(/^[0-9A-F]+$/i)
    end
  end
end
