class RoomsController < ApplicationController
  def index
    respond_to do |format|
      format.datatable {
        contracts = Contract.rooms.all(include: [:buyer, :seller, :last_payment])
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
    @contract = Contract.rooms.find(params[:id])
  end

  def new
    @contract = Contract.new
    @contract.seller = current_user
  end

  def create
    @contract = Contract.new(
      name: params[:contract][:name],
      duration_months: params[:contract][:duration_months],
      type: Contract::TYPE_ROOM,
    )
    @contract.name += '@conference.syriatalk.biz' unless @contract.name.include?('@')
    @contract.seller = current_user
    @contract.buyer = User.find_by_name(params[:contract][:buyer])
    if @contract.save
      redirect_to @contract
    else
      @contract.name.sub!('@conference.syriatalk.biz', '')
      render :new
    end
  end
end
