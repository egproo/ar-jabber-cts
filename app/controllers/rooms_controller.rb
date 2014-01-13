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
    @room.seller = current_user
  end

  def create
    @room = Room.new(
      name: params[:room][:name],
      duration_months: params[:room][:duration_months],
    )
    @room.name += '@conference.syriatalk.biz' unless @room.name.include?('@')
    @room.seller = current_user
    @room.buyer = User.find_by_name(params[:room][:buyer])
    if @room.save
      redirect_to @room
    else
      @room.name.sub!('@conference.syriatalk.biz', '')
      render :new
    end
  end
end
