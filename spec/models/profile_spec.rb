require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:profile) { build(:profile) }
  let(:blank_profile) { build(:blank_profile) }

  describe 'associations' do
    context 'user' do
      it 'belongs_to user' do
        expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
      end
    end
  end

  describe 'validations' do

    context '#name' do
      it 'is not valid when blank' do
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:name]).to include("can't be blank")
      end

      it 'is not valid when length < 2' do
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:name]).to include(/too short/)
      end

      it 'is not valid when length > 50' do
        blank_profile.name = 'x' * 51
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:name]).to include(/too long/)
      end

      it 'is valid' do
        expect(profile).to be_valid
      end
    end

    context '#surname' do
      it 'is not valid when blank' do
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:surname]).to include("can't be blank")
      end

      it 'is not valid when length < 2' do
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:surname]).to include(/too short/)
      end

      it 'is not valid when length > 50' do
        blank_profile.surname = 'x' * 51
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:surname]).to include(/too long/)
      end

      it 'is valid' do
        expect(profile).to be_valid
      end
    end

    context '#patronymic' do
      it 'is not valid when blank' do
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:patronymic]).to include("can't be blank")
      end

      it 'is not valid when length < 5' do
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:patronymic]).to include(/too short/)
      end

      it 'is not valid when length > 50' do
        blank_profile.patronymic = 'x' * 51
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:patronymic]).to include(/too long/)
      end

      it 'is valid' do
        expect(profile).to be_valid
      end
    end

    context '#phone_number' do
      it 'is not valid when blank' do
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:phone_number]).to include("can't be blank")
      end

      it 'is not valid when length < 7' do
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:phone_number]).to include(/too short/)
      end

      it 'is not valid when length > 13' do
        blank_profile.phone_number = '7' * 14
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:phone_number]).to include(/too long/)
      end

      it 'is valid with correct phone number' do
        expect(profile).to be_valid
      end
    end

    context '#passport_code' do
      it 'is not valid when blank' do
        expect(blank_profile).to_not be_valid
        expect(blank_profile.errors[:passport_code]).to include("can't be blank")
      end

      it 'is not valid with incorrect format' do
        blank_profile.passport_code = 'kkz2313413'
        expect(blank_profile).to_not be_valid

        blank_profile.passport_code = 'kkz231342'
        expect(blank_profile).to_not be_valid
      end

      it 'is valid with correct format' do
        expect(profile).to be_valid
      end
    end

  end

  describe 'callbacks' do
    context 'before_save' do
      it '#upcase_passport_code' do
        example_passport_code = 'kh1234321'
        profile.passport_code = example_passport_code
        profile.save
        expect(profile.passport_code).to eq(example_passport_code.upcase)
      end
    end
  end
end
