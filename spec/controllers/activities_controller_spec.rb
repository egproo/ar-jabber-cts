require 'spec_helper'

describe ActivitiesController do
  before(:each) do
    user = create(:user)
    sign_in user
  end

  describe 'GET index' do
    it 'it has a 200 status code' do
      get :index
      expect(response.status).to eq(200)
    end
  end

end
