class ContractsController < ApplicationController
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
    @contract = Room.find(params[:id])
  end

  def new
    @contract = Room.new
    @contract.seller = current_user
  end

  def create
    @contract = Room.new(
      name: params[:contract][:name],
      duration_months: params[:contract][:duration_months],
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
