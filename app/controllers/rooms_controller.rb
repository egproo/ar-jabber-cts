class RoomsController < ApplicationController
  def index
    respond_to do |format|
      format.datatable {
        contracts = Room.all(include: [:buyer, :seller, :last_payment])
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
    @room.payments.build
  end

  def create
    @room = Room.new(
      name: params[:room][:name],
      duration_months: params[:room][:duration_months],
    )
    @room.name += '@conference.syriatalk.biz' unless @room.name.include?('@')
    @room.seller = current_user
    @room.buyer = User.find_by_name(params[:room][:buyer_attributes][:name]) ||
                  User.new(params[:room][:buyer_attributes].merge(role: User::ROLE_CLIENT))

    money_transfer = MoneyTransfer.new(
      sender: @room.buyer,
      receiver: @room.seller,
      amount: params[:room][:payments_attributes].values.first[:amount],
      received_at: Time.now,
    )
    payment = money_transfer.payments.build(
      contract: @room,
      amount: money_transfer.amount,
    )

    @room.payments << payment

    begin
      Room.transaction do
        money_transfer.save!
        @room.save!
      end
      redirect_to @room
    rescue
      Rails.logger.debug(@room.errors.inspect + payment.errors.inspect)
      Rails.logger.debug $!.inspect
      @room.name.sub!('@conference.syriatalk.biz', '')
      render :new
    end
  end
end
