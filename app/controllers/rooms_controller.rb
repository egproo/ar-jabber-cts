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

  def edit
    @room = Room.find(params[:id])
    @room.name.sub!('@conference.syriatalk.biz', '')
    @room.payments.build(money_transfer: MoneyTransfer.new(received_at: Time.now.to_date))
  end

  def update
    @room = Room.find(params[:id])

    if params[:room][:buyer_attributes][:name] != @room.buyer.name
      @room.deactivate(false).save!
      @room = new_or_existing_room(params[:room])
    else
      @room.comment = params[:room][:comment]
    end

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

  def new
    @room = Room.new
    @room.buyer = User.new
    @room.seller = current_user
    @room.payments.build(money_transfer: MoneyTransfer.new(received_at: Time.now.to_date))
  end

  def create
    @room = new_or_existing_room(params[:room])

    if @room.save
      #Ejabberd.new.room(@room.name).create(@room.buyer.jid)
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
    Room.active.find(params[:id]).deactivate.save!
    render :index
  end

  private
  def new_or_existing_room(attrs)
    room = Room.new(
      name: attrs[:name],
      active: true,
      comment: attrs[:comment],
    )

    room.name += '@conference.syriatalk.biz' unless room.name.include?('@')
    room.seller = current_user
    room.buyer = User.find_by_name(attrs[:buyer_attributes][:name]) ||
                 User.new(attrs[:buyer_attributes].merge(role: User::ROLE_CLIENT))
    
    if existing_room = Room.first(
          conditions: {
            name: room.name,
            seller_id: room.seller,
            buyer_id: room.buyer,
            active: false,
          })
      room = existing_room
      room.active = true
      room.comment = attrs[:comment] || room.comment
    end

    payment_hash = attrs[:payment_attributes]
    money_transfer = MoneyTransfer.new(
      sender: room.buyer,
      receiver: room.seller,
      amount: payment_hash[:amount],
      received_at: payment_hash[:money_transfer_attributes][:received_at],
    )
    payment = money_transfer.payments.build(
      contract: room,
      amount: money_transfer.amount,
      effective_months: payment_hash[:effective_months]
    )

    room.payments << payment

    room
  end
end
