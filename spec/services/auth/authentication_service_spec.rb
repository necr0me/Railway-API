require 'rails_helper'

RSpec.describe Auth::AuthenticationService do
  let(:user) { create(:user) }

  describe 'when email is invalid' do
    it 'success? value is false, contains error and doesnt return user' do
      result = described_class.call(user_params: { email: ' ', password: ' '})

      expect(result.success?).to eq(false)

      expect(result.errors).to include('Can\'t find user with such email')

      expect(result.user).to be_nil
    end
  end

  describe 'when password is invalid' do
     it 'success? value is false, contains error message and does not return user' do
       result = described_class.call(user_params: { email: user.email, password: ' '})

       expect(result.success?).to eq(false)

       expect(result.errors).to include('Invalid password')

       expect(result.user).to be_nil
    end
  end

  describe 'when credentials are correct' do
    it 'success? value is true, does not contains any errors and returns correct user' do
      result = described_class.call(user_params: { email: user.email, password: user.password } )

      expect(result.success?).to eq(true)

      expect(result.errors).to be_nil

      expect(result.user).to_not be_nil
      expect(result.user.id).to eq(user.id)
    end
  end
end