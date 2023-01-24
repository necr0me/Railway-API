require 'rails_helper'

RSpec.describe Jwt::EncoderService do
  let(:user) { create(:user) }

  describe '#call' do
    context 'refresh token' do
      before do
        @refresh_token = described_class.call(
          payload: { user_id: user.id },
          type: 'refresh'
        )
        @secret_key = Constants::Jwt::JWT_SECRET_KEYS['refresh']
        @options = { algorithm: Constants::Jwt::JWT_ALGORITHM }
      end

      it 'contains \'exp\' and \'iat\' fields, expires in 30 days and hashes all payload' do
        decoded = JWT.decode(@refresh_token,
                             @secret_key,
                             @options).first
        expect(decoded['exp']).to_not be_nil

        expect(decoded['iat']).to_not be_nil

        expires_in = decoded['exp'] - Time.now.to_i
        expect(expires_in).to be_between(29.days.to_i, 31.days.to_i)

        expect(JSON.generate(decoded)).to_not eq(@refresh_token)
      end
    end

    context 'access token' do
      before do
        @access_token = described_class.call(
          payload: { user_id: user.id },
          type: 'access'
        )
        @secret_key = Constants::Jwt::JWT_SECRET_KEYS['access']
        @options = { algorithm: Constants::Jwt::JWT_ALGORITHM }
      end

      it 'contains \'exp\' and \'iat\' fields, expires in 30 minutes and hashes all payload' do
        decoded = JWT.decode(@access_token,
                             @secret_key,
                             @options).first
        expect(decoded['exp']).to_not be_nil

        expect(decoded['iat']).to_not be_nil

        expires_in = decoded['exp'] - Time.now.to_i
        expect(expires_in).to be_between(29.minutes.to_i, 31.minutes.to_i)

        expect(JSON.generate(decoded)).to_not eq(@access_token)
      end
    end
  end
end