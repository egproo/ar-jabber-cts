class UsersController < ApplicationController
  def home
    @user = (
        current_user.role == User::ROLE_ADMIN &&
        User.find_by_name(params[:username])
      ) || current_user
    render :show
  end

  def show
    @user = User.find(params[:id])
    if current_user.role <= User::ROLE_SUPER_MANAGER
      return render text: 'This user does not have contracts with you' unless current_user == @user || current_user.clients.include?(@user)
    end
  end

  def index
    @users = current_user.role >= User::ROLE_SUPER_MANAGER ? User.all : current_user.clients.uniq

    respond_to do |format|
      format.datatable { render json: { aaData: @users }, except: [:password] }
      format.json { render json: @users.map(&:name) }
      format.html
    end
  end

  def update
    user = User.find(params[:id])
    user.password = params[:user][:password]
    user.save!
    redirect_to user
  end
end
