require 'spec_helper'

describe UsersController do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe 'GET #index' do
    it 'has a 200 status code' do
      get :index
      expect(response.status).to eq(200)
    end

    # TODO: make test pass
    #it 'assigns all users to @users' do
      #get :index
      #expect(assigns(:users)).to match_array([user])
    #end
  end

  describe 'GET #show' do
    it 'has a 200 status code' do
      get :show, id: user
      expect(response.status).to eq(200)
    end

    it 'assigns the requested user to @user' do
      get :show, id: user
      expect(assigns(:user)).to eq(user)
    end
  end

end
