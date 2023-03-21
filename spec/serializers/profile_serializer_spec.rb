require 'rails_helper'

RSpec.describe ProfileSerializer do
  let(:profile) { create(:profile) }
  let(:serializer) { described_class.new(profile) }
  let(:result) { serializer.serializable_hash[:data] }

  describe 'attributes' do
    it 'has name, surname, patronymic, phone number and passport code attributes, type is profile, id is correct' do
      expect(result[:type]).to eq(:profile)
      expect(result[:id]).to eq(profile.id.to_s)

      expect(result[:attributes]).to eq({
                                          name: profile.name,
                                          surname: profile.surname,
                                          patronymic: profile.patronymic,
                                          phone_number: profile.phone_number,
                                          passport_code: profile.passport_code
                                        })
    end
  end
end
