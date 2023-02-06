require 'rails_helper'

RSpec.describe Jwt::TokensGeneratorService do
  let(:user) { create(:user) }
  let(:user_with_token) { create(:user, :user_with_refresh_token) }

  let(:generate_tokens_for_user) { described_class.call(user_id: user.id).data }
  let(:generate_tokens_for_user_with_token) { described_class.call(user_id: user_with_token.id).data }


  describe '#call' do
    context 'when error occurs' do
      before do
        allow_any_instance_of(Jwt::EncoderService).to receive(:call).and_raise('Some error')
      end

      it 'does not generates two tokens and returns error message' do
        result = described_class.call(user_id: user.id)
        expect(result.data).to be_nil
        expect(result.error).to eq('Some error')
      end
    end

    context 'no matter if refresh token exists or not' do
      let(:secret_keys) { Constants::Jwt::JWT_SECRET_KEYS }
      let(:options) { { algorithm: Constants::Jwt::JWT_ALGORITHM} }

      it 'generates two tokens, first one is access, second one is refresh' do
        tokens = generate_tokens_for_user
        access_token, refresh_token = tokens
        expect(generate_tokens_for_user.count).to eq(2)

        expect { JWT.decode(access_token,
                            secret_keys['access'],
                            true,
                            options)}.to_not raise_error

        expect { JWT.decode(refresh_token,
                            secret_keys['refresh'],
                            true,
                            options)}.to_not raise_error
      end
    end

    context 'refresh token of user doesn\'t exists' do
      it 'creates refresh token for user if token is not created' do
        expect(user.refresh_token).to be_nil

        token = generate_tokens_for_user.last

        expect(user.reload.refresh_token).to_not be_nil
        expect(user.refresh_token.value).to eq(token)
      end
    end

    context 'refresh token of user exists' do
      it 'updates refresh token for user if token is already exists' do
        old_token = user_with_token.refresh_token.value
        expect(user_with_token.refresh_token).to_not be_nil

        new_token = generate_tokens_for_user_with_token.last

        expect(user_with_token.reload.refresh_token.value).to eq(new_token)
        expect(user_with_token.refresh_token.value).to_not eq(old_token)
      end
    end
  end

  describe '#create_or_update_refresh_token' do
    let(:token) { OpenStruct.new(data: 'token') }

    context "when user hasn't refresh token in db" do
      it 'creates refresh token in db' do
        service = described_class.new(user_id: user.id)
        expect_any_instance_of(User).to receive(:create_refresh_token)
        service.send(:create_or_update_refresh_token, token)
      end
    end

    context 'when user has refresh token in db' do
      it 'updates refresh token in db' do
        service = described_class.new(user_id: user_with_token.id)
        expect_any_instance_of(RefreshToken).to receive(:update)
        service.send(:create_or_update_refresh_token, token)
      end
    end
  end

  describe '#user' do
    context 'using method first time' do
      it 'finds correct user' do
        service = described_class.new(user_id: user.id)
        # TODO: test with expect.to receive(:find)
        expect(service.send(:user)&.id).to eq(user.id)
      end
    end

    context 'using method not first time' do
      it 'returns memoized user' do
        service = described_class.new(user_id: user.id)
        service.instance_variable_set '@user', user

        expect(User).to_not receive(:find)
        expect(service.send(:user).id).to eq(user.id)
      end
    end
  end
end
