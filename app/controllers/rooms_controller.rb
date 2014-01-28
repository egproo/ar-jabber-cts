class RoomsController < ApplicationController
  def index
    respond_to do |format|
      format.js { @rooms = Room.active.sold_by(current_user).all(include: [:buyer, :seller, :last_payment]) }
      format.html
    end
  end

  def show
    @room = Room.find(params[:id])
  end

  def new
    @room = Room.new
    @room.buyer = User.new
    @room.seller = current_user
    @room.payments.build(money_transfer: MoneyTransfer.new(received_at: Time.now.to_date))
  end

  def create
    @room = Room.new(
      name: params[:room][:name],
      active: true,
      comment: params[:room][:comment],
    )
    @room.name += '@conference.syriatalk.biz' unless @room.name.include?('@')
    @room.seller = current_user
    @room.buyer = User.find_by_name(params[:room][:buyer_attributes][:name]) ||
                  User.new(params[:room][:buyer_attributes].merge(role: User::ROLE_CLIENT))
    

    payment_hash = params[:room][:payments_attributes].values.first
    money_transfer = MoneyTransfer.new(
      sender: @room.buyer,
      receiver: @room.seller,
      amount: payment_hash[:amount],
      received_at: payment_hash[:money_transfer_attributes][:received_at],
    )
    payment = money_transfer.payments.build(
      contract: @room,
      amount: money_transfer.amount,
      effective_months: payment_hash[:effective_months]
    )

    @room.payments << payment

    if @room.save
      if request.xhr?
        render status: 200, json: { location: Rails.application.routes.url_helpers.room_path(@room) }
      else
        redirect_to @room
      end
    else
      @room.name.sub!('@conference.syriatalk.biz', '')
      render :new, status: 400, layout: !request.xhr?
    end
  end

  def destroy
    r = Room.active.find(params[:id])
    r.active = false
    r.backup!
    r.save!
    r.erase!

    render :index
  end
end
