require 'rails_helper'

RSpec.describe Auth::AuthorizationService do
  let(:user) { create(:user) }
  let(:access_token) { JWT.encode({ user_id: user.id},
                                  Constants::Jwt::JWT_SECRET_KEYS['access'],
                                  Constants::Jwt::JWT_ALGORITHM) }
  let(:expired_access_token) { JWT.encode({ user_id: user.id, exp: Time.now.to_i - 1.minutes.to_i },
                                          Constants::Jwt::JWT_SECRET_KEYS['access'],
                                          Constants::Jwt::JWT_ALGORITHM) }
  let(:refresh_token) { JWT.encode({ user_id: user.id},
                                   Constants::Jwt::JWT_SECRET_KEYS['refresh'],
                                   Constants::Jwt::JWT_ALGORITHM) }

  describe 'when authorization header is not presented' do
    it 'success? value is false, contains error message and does not returns decoded token ' do
      result = described_class.call(authorization_header: nil)

      expect(result.success?).to eq(false)

      expect(result.errors).to include('Authorization header is not presented')

      expect(result.data).to be_nil
    end
  end

  describe 'when refresh token presented instead of access token' do
    it 'success? value is false, contains error message and does not returns decoded token' do
      result = described_class.call(authorization_header: "Bearer #{refresh_token}")

      expect(result.success?).to eq(false)

      expect(result.errors).to include('Signature verification failed')

      expect(result.data).to be_nil
    end
  end

  describe 'when access token is expired' do
    it 'success? value is false, contains error message and does not returns decoded token' do
      result = described_class.call(authorization_header: "Bearer #{expired_access_token}")

      expect(result.success?).to eq(false)

      expect(result.errors).to include('Signature has expired')

      expect(result.data).to be_nil
    end
  end

  describe 'when access token is not presented' do
    it 'success? value is false, contains error message and does not returns decoded token' do
      result = described_class.call(authorization_header: "Bearer")

      expect(result.success?).to eq(false)

      expect(result.errors).to include('Nil JSON web token')

      expect(result.data).to be_nil
    end
  end

  describe 'when access token is presented' do
    it 'success? value is true' do
      result = described_class.call(authorization_header: "Bearer #{access_token}")

      expect(result.success?).to eq(true)

      expect(result.errors).to be_nil

      expect(result.data['user_id']).to eq(user.id)
    end
  end
end