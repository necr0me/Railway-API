RSpec.describe Jwt::EncoderService do
  subject(:service) { described_class.call(payload: payload, type: token_type) }

  let(:payload) { { user_id: "1337" } }
  let(:options) { { algorithm: Constants::Jwt::JWT_ALGORITHM } }

  describe "#call" do
    describe "refresh token" do
      let(:token_type) { "refresh" }
      let(:secret) { Constants::Jwt::JWT_SECRET_KEYS[token_type] }
      let(:refresh_token) { subject.data }

      context "when error occurs" do
        before do
          allow(JWT).to receive(:encode).and_raise("Some error")
        end

        it "does not contains encoded token and returns error message" do
          expect(service.data).to be_nil
          expect(service.error).to eq("Some error")
        end
      end

      context "when no errors occurs" do
        it "contains 'exp' and 'iat' fields, expires in 30 days and hashes all payload" do
          decoded = JWT.decode(refresh_token, secret, options).first
          expect(decoded["exp"]).not_to be_nil

          expect(decoded["iat"]).not_to be_nil

          expires_in = decoded["exp"] - Time.now.to_i
          expect(expires_in).to be_between(29.days.to_i, 31.days.to_i)

          expect(JSON.generate(decoded)).not_to eq(refresh_token)
        end
      end
    end

    describe "access token" do
      let(:token_type) { "access" }
      let(:secret) { Constants::Jwt::JWT_SECRET_KEYS[token_type] }
      let(:access_token) { subject.data }

      context "when error occurs" do
        before do
          allow(JWT).to receive(:encode).and_raise("Some error")
        end

        it "does not contains encoded token and returns error message" do
          expect(service.data).to be_nil
          expect(service.error).to eq("Some error")
        end
      end

      context "when no errors occurs" do
        it "contains 'exp' and 'iat' fields, expires in 30 minutes and hashes all payload" do
          decoded = JWT.decode(access_token, secret, options).first
          expect(decoded["exp"]).not_to be_nil

          expect(decoded["iat"]).not_to be_nil

          expires_in = decoded["exp"] - Time.now.to_i
          expect(expires_in).to be_between(29.minutes.to_i, 31.minutes.to_i)

          expect(JSON.generate(decoded)).not_to eq(access_token)
        end
      end
    end
  end
end
