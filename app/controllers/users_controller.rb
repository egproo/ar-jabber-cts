class UsersController < ApplicationController
  load_and_authorize_resource

  def new
  end

  def create
=begin
    @user = User.new(
      role: User::ROLE_CLIENT,
      jid: params[:user][:jid],
      name: (params[:user][:name].present? && params[:user][:name]) || params[:user][:jid].to_s.split('@', 2)[0],
      phone: params[:user][:phone],
    )

    if @user.save
      redirect_to @user
    else
      render :new
    end
=end
  end

  def show
  end

  def index
    respond_to do |format|
      format.json { render json: @users.map(&:name) }
      format.html
    end
  end

  def update
    @user.password = params[:user][:password]
    @user.save!
    redirect_to @user
  end
end
