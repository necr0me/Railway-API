

RSpec.describe Jwt::TokensGeneratorService do
  let(:generate_tokens_for_user) { described_class.call(user_id: user.id).data }
  let(:generate_tokens_for_user_with_token) { described_class.call(user_id: user_with_token.id).data }

  let(:user) { create(:user) }
  let(:user_with_token) { create(:user, :user_with_refresh_token) }

  describe "#call" do
    context "when error occurs" do
      before do
        allow_any_instance_of(Jwt::EncoderService).to receive(:call).and_raise("Some error")
      end

      it "does not generates two tokens and returns error message" do
        result = described_class.call(user_id: user.id)
        expect(result.data).to be_nil
        expect(result.error).to eq("Some error")
      end
    end

    context "when no matter if refresh token exists or not" do
      let(:secret_keys) { Constants::Jwt::JWT_SECRET_KEYS }
      let(:options) { { algorithm: Constants::Jwt::JWT_ALGORITHM } }

      def decode_token(token, type)
        JWT.decode(token, secret_keys[type], true, options)
      end

      it "generates two tokens, first one is access, second one is refresh" do
        tokens = generate_tokens_for_user
        access_token, refresh_token = tokens
        expect(generate_tokens_for_user.count).to eq(2)

        expect { decode_token(access_token, "access") }.not_to raise_error

        expect { decode_token(refresh_token, "refresh") }.not_to raise_error
      end
    end

    context "when refresh token of user doesn't exists" do
      it "creates refresh token for user if token is not created" do
        expect(user.refresh_token).to be_nil

        token = generate_tokens_for_user.last

        expect(user.reload.refresh_token).not_to be_nil
        expect(user.refresh_token.value).to eq(token)
      end
    end

    context "when refresh token of user exists" do
      it "updates refresh token for user if token is already exists" do
        old_token = user_with_token.refresh_token.value
        expect(user_with_token.refresh_token).not_to be_nil

        new_token = generate_tokens_for_user_with_token.last

        expect(user_with_token.reload.refresh_token.value).to eq(new_token)
        expect(user_with_token.refresh_token.value).not_to eq(old_token)
      end
    end
  end

  describe "#create_or_update_refresh_token" do
    let(:token) { OpenStruct.new(data: "token") }

    context "when user hasn't refresh token in db" do
      it "creates refresh token in db" do
        service = described_class.new(user_id: user.id)
        expect_any_instance_of(User).to receive(:create_refresh_token)
        service.send(:create_or_update_refresh_token, token)
      end
    end

    context "when user has refresh token in db" do
      it "updates refresh token in db" do
        service = described_class.new(user_id: user_with_token.id)
        expect_any_instance_of(RefreshToken).to receive(:update)
        service.send(:create_or_update_refresh_token, token)
      end
    end
  end

  describe "#user" do
    context "when using method first time" do
      it "finds correct user" do
        service = described_class.new(user_id: user.id)
        expect_any_instance_of(User.const_get(:ActiveRecord_Relation)).to receive(:find).with(user.id).and_return(user)

        expect(service.send(:user).id).to eq(user.id)
      end
    end

    context "when using method not first time" do
      it "returns memoized user" do
        service = described_class.new(user_id: user.id)
        service.instance_variable_set "@user", user

        expect_any_instance_of(User.const_get(:ActiveRecord_Relation)).not_to receive(:find)
        expect(service.send(:user).id).to eq(user.id)
      end
    end
  end
end
