require 'rails_helper'

RSpec.describe ErrorHandler do
  describe '#record_not_found' do
    controller(ActionController::API) do
      include ErrorHandler

      def action
        raise ActiveRecord::RecordNotFound.new "Can't find this record"
      end
    end

    before do
      routes.draw { get :action, to: 'anonymous#action'}
      get :action
    end

    it 'returns 404' do
      expect(response.status).to eq(404)
    end

    it 'contains error message' do
      expect(json_response['message']).to eq("Can't find this record")
    end
  end

  describe '#record_not_unique' do
    controller(ApplicationController) do
      include ErrorHandler

      def action
        raise ActiveRecord::RecordNotUnique
      end
    end

    before do
      routes.draw { get :action, to: 'anonymous#action' }
      get :action
    end

    it 'returns 422' do
      expect(response.status).to eq(422)
    end

    it 'contains message that record already exists' do
      expect(json_response['message']).to eq("Seems like record with this data already exists")
    end
  end

  describe '#access_forbidden' do
    controller(ApplicationController) do
      include ErrorHandler

      def action
        raise Pundit::NotAuthorizedError
      end
    end

    before do
      routes.draw { get :action, to: 'anonymous#action' }
      get :action
    end

    it 'returns 403' do
      expect(response.status).to eq(403)
    end

    it 'contains message that you are not allowed to do this action' do
      expect(json_response['message']).to eq('You are not allowed to do this action')
    end
  end
end