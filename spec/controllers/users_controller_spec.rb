require 'spec_helper'

describe UsersController do

  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }

  before(:each) do
    sign_in admin
  end

  describe 'GET #index' do
    it 'has a 200 status code' do
      get :index
      expect(response.status).to eq(200)
    end

    it 'assigns all users to @users' do
      # @users contain two created users
      get :index
      expect(assigns(:users)).to match_array([admin, user])
    end
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

  describe '#switch' do
    it 'changes @effective_user' do
      get :show, id: user
      expect(session[:effective_user_id]).to eq(nil)

      get :switch, id: user
      expect(session[:effective_user_id]).to eq(user.id.to_s)
    end

    it 'redirects to the root' do
      get :switch, id: user
      expect(response).to redirect_to :root
    end

    describe '#update' do
      it 'redirects to the @user' do
        put :update, id: user, user: FactoryGirl.attributes_for(:user)
        expect(response).to redirect_to user
      end
    end
  end

end
