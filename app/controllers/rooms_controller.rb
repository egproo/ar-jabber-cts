class RoomsController < ApplicationController
  def index
    respond_to do |format|
      format.datatable {
        contracts = Room.all(include: [:buyer, :seller, { last_payment: :money_transfer }])
        render json: {
            aaData: contracts
          },
          include: [
            { buyer: { except: [:password] } },
            { seller: { except: [:password] } },
            :last_payment
          ],
          methods: [:next_payment_date]
      }
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
      duration_months: params[:room][:duration_months],
      active: true,
    )
    @room.name += '@conference.syriatalk.biz' unless @room.name.include?('@')
    @room.seller = current_user
    @room.buyer = User.find_by_name(params[:room][:buyer_attributes][:name]) ||
                  User.new(params[:room][:buyer_attributes].merge(role: User::ROLE_CLIENT))

    money_transfer = MoneyTransfer.new(
      sender: @room.buyer,
      receiver: @room.seller,
      amount: params[:room][:payments_attributes].values.first[:amount],
      received_at: params[:room][:payments_attributes].values.first[:money_transfer_attributes][:received_at],
    )
    payment = money_transfer.payments.build(
      contract: @room,
      amount: money_transfer.amount,
      money_transfer: money_transfer,
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
    Room.find(params[:id]).update_attributes(active: false)
    render :index
  end
end
