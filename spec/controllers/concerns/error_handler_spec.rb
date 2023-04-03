RSpec.describe ErrorHandler do
  describe "#record_not_found" do
    controller(ActionController::API) do
      include ErrorHandler

      def action
        raise ActiveRecord::RecordNotFound, "Can't find this record"
      end
    end

    before do
      routes.draw { get :action, to: "anonymous#action" }
      get :action
    end

    it "returns 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "contains error message" do
      expect(json_response[:message]).to eq("Can't find this record")
    end
  end

  describe "#record_not_unique" do
    controller(ApplicationController) do
      include ErrorHandler

      def action
        raise ActiveRecord::RecordNotUnique
      end
    end

    before do
      routes.draw { get :action, to: "anonymous#action" }
      get :action
    end

    it "returns 422" do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "contains message that record already exists" do
      expect(json_response[:message]).to eq("Seems like record with this data already exists")
    end
  end

  describe "#invalid_foreign_key" do
    controller(ApplicationController) do
      include ErrorHandler

      def action
        raise ActiveRecord::InvalidForeignKey
      end
    end

    before do
      routes.draw { get :action, to: "anonymous#action" }
      get :action
    end

    it "returns 422" do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "contains message that entity with this foreign key does not exist" do
      expect(json_response[:message]).to eq("Seems like this entity does not exist")
    end
  end

  describe "#access_forbidden" do
    controller(ApplicationController) do
      include ErrorHandler

      def action
        raise Pundit::NotAuthorizedError
      end
    end

    before do
      routes.draw { get :action, to: "anonymous#action" }
      get :action
    end

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end

    it "contains message that you are not allowed to do this action" do
      expect(json_response[:message]).to eq("You are not allowed to do this action")
    end
  end
end
