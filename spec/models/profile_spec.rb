RSpec.describe Profile, type: :model do
  let(:profile) { build(:profile) }
  let(:blank_profile) { build(:blank_profile) }

  describe "associations" do
    describe "user" do
      it "belongs_to user" do
        expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
      end
    end
  end

  describe "auto_strip_attributes" do
    describe "#name" do
      it "removes redundant whitespaces at start and at the end" do
        profile.name = "\s\s\sName with whitespaces\s\s\s"
        profile.save
        expect(profile.name.count(" ")).to eq(2)
      end

      it "removes tabulations" do
        profile.name = "\t\t\tName\t\t\twith\t\t\ttabulations\t\t\t"
        profile.save
        expect(profile.name.count(" ")).to eq(2)
      end
    end

    describe "#surname" do
      it "removes redundant whitespaces at start and at the end" do
        profile.surname = "\s\s\sSurname with whitespaces\s\s\s"
        profile.save
        expect(profile.surname.count(" ")).to eq(2)
      end

      it "removes tabulations" do
        profile.surname = "\t\t\tSurname\t\t\twith\t\t\ttabulations\t\t\t"
        profile.save
        expect(profile.surname.count(" ")).to eq(2)
      end
    end

    describe "#patronymic" do
      it "removes redundant whitespaces at start and at the end" do
        profile.patronymic = "\s\s\sPatronymic with whitespaces\s\s\s"
        profile.save
        expect(profile.patronymic.count(" ")).to eq(2)
      end

      it "removes tabulations" do
        profile.patronymic = "\t\t\tPatronymic\t\t\twith\t\t\ttabulations\t\t\t"
        profile.save
        expect(profile.patronymic.count(" ")).to eq(2)
      end
    end

    describe "#phone_number" do
      it "removes any whitespaces" do
        profile.phone_number = "\s+3\s75\s33\s7\s53\s\s12\s111\s\s\s"
        profile.save
        expect(profile.phone_number.count(" ")).to eq(0)
      end
    end
  end

  describe "validations" do
    describe "#name" do
      context "when name is blank" do
        it "is not valid" do
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:name]).to include("can't be blank")
        end
      end

      context "when name is too short (less than 2 characters)" do
        it "is not valid " do
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:name]).to include(/too short/)
        end
      end

      context "when name is too long (more than 50 characters)" do
        it "is not valid" do
          blank_profile.name = "x" * 51
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:name]).to include(/too long/)
        end
      end

      context "when name is not blank, length is correct" do
        it "is valid" do
          expect(profile).to be_valid
        end
      end
    end

    describe "#surname" do
      context "when surname is blank" do
        it "is not valid" do
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:surname]).to include("can't be blank")
        end
      end

      context "when surname is too short (less than 2 characters)" do
        it "is not valid" do
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:surname]).to include(/too short/)
        end
      end

      context "when surname is too long (more than 50 characters)" do
        it "is not valid" do
          blank_profile.surname = "x" * 51
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:surname]).to include(/too long/)
        end
      end

      context "when surname is not blank, length is correct" do
        it "is valid" do
          expect(profile).to be_valid
        end
      end
    end

    describe "#patronymic" do
      context "when patronymic is blank" do
        it "is not valid" do
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:patronymic]).to include("can't be blank")
        end
      end

      context "when patronymic is too short (less than 2 characters)" do
        it "is not valid" do
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:patronymic]).to include(/too short/)
        end
      end

      context "when patronymic is too long (more than 50 characters)" do
        it "is not valid" do
          blank_profile.patronymic = "x" * 51
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:patronymic]).to include(/too long/)
        end
      end

      context "when patronymic is not blank, length is correct" do
        it "is valid" do
          expect(profile).to be_valid
        end
      end
    end

    describe "#phone_number" do
      context "when phone number is blank" do
        it "is not valid" do
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:phone_number]).to include("can't be blank")
        end
      end

      context "when phone number is too short (less than 7 characters)" do
        it "is not valid" do
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:phone_number]).to include(/too short/)
        end
      end

      context "when phone number is too long (more than 13 characters)" do
        it "is not valid" do
          blank_profile.phone_number = "7" * 14
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:phone_number]).to include(/too long/)
        end
      end

      context "when phone number is not blank, length is correct" do
        it "is valid" do
          expect(profile).to be_valid
        end
      end
    end

    describe "#passport_code" do
      context "when passport code is blank" do
        it "is not valid" do
          expect(blank_profile).not_to be_valid
          expect(blank_profile.errors[:passport_code]).to include("can't be blank")
        end
      end

      context "when passport code has incorrect format" do
        it "is not valid" do
          blank_profile.passport_code = "kkz2313413"
          expect(blank_profile).not_to be_valid

          blank_profile.passport_code = "kkz231342"
          expect(blank_profile).not_to be_valid
        end
      end

      context "when passport code is not blank, format is correct" do
        it "is valid" do
          expect(profile).to be_valid
        end
      end
    end
  end

  describe "callbacks" do
    describe "before_save" do
      it "#upcase_passport_code" do
        example_passport_code = "kh1234321"
        profile.passport_code = example_passport_code
        profile.save
        expect(profile.passport_code).to eq(example_passport_code.upcase)
      end
    end
  end
end
