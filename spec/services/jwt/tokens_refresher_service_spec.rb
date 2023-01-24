require 'rails_helper'

RSpec.describe Jwt::TokensRefresherService do
  let(:user) { create(:user, :user_with_refresh_token) }
  let(:secret_key) { Constants::Jwt::JWT_SECRET_KEYS['refresh'] }
  let(:secret_access_key) { Constants::Jwt::JWT_SECRET_KEYS['access'] }
  let(:algorithm) { Constants::Jwt::JWT_ALGORITHM }

  describe '#refresh_tokens' do
    context 'no refresh token presented' do
      subject { described_class.call(refresh_token: nil) }

      it 'success? value is false, contains error message and does not returns tokens' do
        result = described_class.call(refresh_token: nil)

        expect(result.success?).to eq(false)

        expect(result.errors).to include(/Nil JSON/)

        expect(result.tokens).to be_nil
      end
    end


    context 'presented refresh token and refresh token in db are not matching' do
      it 'success? value is false, contains error message and does not returns tokens' do
        result = described_class.call(refresh_token: JWT.encode({ user_id: user.id }, secret_key, algorithm))

        expect(result.success?).to eq(false)

        expect(result.errors).to include('Tokens aren\'t matching')

        expect(result.tokens).to be_nil
      end
    end

    context 'expired refresh token presented' do
      before do
        user.refresh_token.update(value: JWT.encode({ user_id: user.id, exp: Time.now.to_i - 1.minutes.to_i },
                                                    secret_key,
                                                    algorithm))
      end

      it 'success? value is false, contains error message and does not returns tokens' do
        result = described_class.call(refresh_token: user.reload.refresh_token.value)

        expect(result.success?).to eq(false)

        expect(result.errors).to include('Signature has expired')

        expect(result.tokens).to be_nil
      end
    end

    context 'access token presented instead of refresh token' do
      it 'success? value is false, contains error message and does not returns tokens' do
        result = described_class.call(refresh_token: JWT.encode({ user_id: user.id},
                                                                secret_access_key,
                                                                algorithm))

        expect(result.success?).to eq(false)

        expect(result.errors).to include('Signature verification failed')

        expect(result.tokens).to be_nil
      end
    end

    context 'correct refresh token presented' do
     before do
        user.refresh_token.update(value: JWT.encode({ user_id: user.id },
                                                    secret_key,
                                                    algorithm))
      end

      it 'success? value is true, no errors, returns 2 tokens and updates refresh token in db' do
        old_token = user.reload.refresh_token.value
        result = described_class.call(refresh_token: user.reload.refresh_token.value)
        new_token = result.tokens.last

        expect(result.success?).to eq(true)

        expect(result.errors).to be_nil

        expect(result.tokens.count).to eq(2)

        expect(user.reload.refresh_token.value).to eq(new_token)
        expect(user.refresh_token.value).to_not eq(old_token)
      end
    end
  end
end