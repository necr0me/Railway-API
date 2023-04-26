module Admin
  class AdminController < ApplicationController
    before_action :authorize!

    def authorize(record, query = nil)
      super([:admin, record], query)
    end
  end
end
