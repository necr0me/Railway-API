require 'rails_helper'

RSpec.describe Api::V1::CarriagesController, type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:user_credentials) { user; attributes_for(:user) }


end
