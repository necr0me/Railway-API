RSpec.describe "Users::Registrations", type: :request do
  let(:user) { build(:user) }
  let(:existing_user) { create(:user) }

  describe "#sign_up" do
    context "when user tries to register with invalid data" do
      before do
        post "/users/sign_up",
             params: {
               user: {
                 unconfirmed_email: "s",
                 password: " "
               }
             }
      end

      it "returns UNPROCESSABLE_ENTITY and contains error messages" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors][:unconfirmed_email]).to include(/is invalid/)
        expect(json_response[:errors][:password]).to include(/is too short/)
      end
    end

    context "when user tries to register with already taken email" do
      before do
        post "/users/sign_up",
             params: {
               user: {
                 unconfirmed_email: existing_user.email,
                 password: existing_user.password
               }
             }
      end

      it "returns UNPROCESSABLE_ENTITY and contains error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors][:unconfirmed_email]).to include(/has already been taken/)
      end
    end

    context "when user tries to register with valid data" do
      before do
        post "/users/sign_up",
             params: {
               user: {
                 unconfirmed_email: user.email,
                 password: user.email
               }
             }
      end

      it "returns 201 and creates user in db" do
        expect(response).to have_http_status(:created)
        expect(User.find_by(unconfirmed_email: user.email).unconfirmed_email).to eq(user.email)
      end
    end
  end

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/users/#{existing_user.id}"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurs during destroying of user" do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

      before do
        allow(User).to receive(:find)
          .with(existing_user.id)
          .and_return(existing_user)
        allow(existing_user).to receive(:destroy).and_return(false)
        allow(existing_user).to receive(:errors).and_return(errors)

        delete "/users/#{existing_user.id}", headers: auth_header_for(existing_user)
      end

      it "returns UNPROCESSABLE_ENTITY and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when user tries to destroy existing user" do
      before do
        delete "/users/#{existing_user.id}", headers: auth_header_for(existing_user)
      end

      it "returns 204 and deletes user from db" do
        expect(response).to have_http_status(:no_content)
        expect { existing_user.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
