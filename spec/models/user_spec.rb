RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let(:user_with_token) { create(:user, :user_with_refresh_token) }
  let(:user_with_profile) { create(:user, :user_with_profile) }

  describe "validations" do
    describe "#email" do
      context "when email is blank" do
        it "is invalid" do
          user.email = " "
          expect(user).not_to be_valid
        end
      end

      context "when email has incorrect format" do
        it "is invalid" do
          user.email = "mail"
          expect(user).not_to be_valid

          user.email = "m@"
          expect(user).not_to be_valid
        end
      end

      context "when email is too long (more than 64 characters)" do
        it "is invalid" do
          user.email = "mail@mail.ru#{'x' * 64}"
          expect(user).not_to be_valid
        end
      end

      context "when email is not blank, has correct format and length is correct" do
        it "is valid" do
          user.email = "mail@gmail.com"
          expect(user).to be_valid

          user.email = "my_mail_k3k@ya.ru"
          expect(user).to be_valid
        end
      end
    end

    describe "#password" do
      context "when password is blank" do
        it "is invalid" do
          user.password = " "
          expect(user).not_to be_valid
        end
      end

      context "when password is too short (less than 7 symbols)" do
        it "is invalid" do
          user.password = "x" * 6
          expect(user).not_to be_valid
        end
      end

      context "when password is too long (more than 64 symbols)" do
        it "is invalid" do
          user.password = "x" * 65
          expect(user).not_to be_valid
        end
      end

      context "when password is not blank, length is correct" do
        it "is valid" do
          user.password = "password"
          expect(user).to be_valid
        end
      end
    end
  end

  describe "associations" do
    describe "refresh_token" do
      it "user has one refresh_token" do
        expect(described_class.reflect_on_association(:refresh_token).macro).to eq(:has_one)
      end

      it "destroys with user" do
        user_id = user_with_token.id
        user_with_token.destroy
        expect(RefreshToken.find_by(user_id: user_id)).to be_nil
      end
    end

    describe "profiles" do
      it "user has many profiles" do
        expect(described_class.reflect_on_association(:profiles).macro).to eq(:has_many)
      end

      it "destroys with user" do
        user_id = user_with_profile.id
        user_with_profile.destroy
        expect(Profile.find_by(user_id: user_id)).to be_nil
      end
    end

    describe "before_create" do
      describe "#set_default_role" do
        context "when role is not defined" do
          let(:user) { build(:user) }

          it "sets role to :user" do
            user.save
            expect(user.role).to eq("user")
          end
        end

        context "when role is defined" do
          let(:user) { build(:user, role: :admin) }

          it "sets role to :user" do
            user.save
            expect(user.role).not_to eq("user")
          end
        end
      end
    end

    describe "before_save" do
      describe "#downcase_email" do
        let(:user) { build(:user, email: "JOHNDOE@GMAIL.Com") }

        it "downcasing email" do
          expect(user.email).not_to eq(user.email.downcase)
          user.save
          expect(user.email).to eq(user.email.downcase)
        end
      end
    end
  end
end
