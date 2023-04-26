RSpec.describe "Admin::Users", type: :request do
  let!(:user) { create(:user, role: :admin) }

  describe "#destroy" do
    let(:other_user) { create(:user, email: "m@m.m") }

    context "when user is unauthorized" do
      before do
        delete "/admin/users/#{other_user.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized, but error occurs" do
      before do
        allow(User).to receive(:find)
          .with(user.id)
          .and_return(user) # To find current user from access_token
        allow(User).to receive(:find)
          .with(other_user.id)
          .and_return(other_user) # To find other user in before_action :find_user
        allow(other_user).to receive(:destroy).and_return(false)

        delete "/admin/users/#{other_user.id}", headers: auth_header
      end

      it "returns 422 and error messages" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
      end
    end

    context "when user is authorized and no error occurs" do
      before do
        delete "/admin/users/#{other_user.id}", headers: auth_header
      end

      it "returns 204" do
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
