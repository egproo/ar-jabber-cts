class ContractsController < ApplicationController
  def index
    contracts = Contract.all(include: [:buyer, :seller, :payments]).map do |contract|
      [
        contract.name,
        contract.buyer,
        contract.seller,
        contract.created_at,
        contract.duration_months,
        contract.last_payment.try(:amount),
        contract.last_payment.try(:created_at),
        contract.next_payment_date,
        contract.next_amount_estimate,
      ]
    end
    respond_to do |format|
      format.datatable { render json: { aaData: contracts } }
      format.xml { render xml: contracts }
      format.html
    end
  end

  def show
    @contract = Contract.find(params[:id])
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
    @contract.seller = current_user
    @contract.buyer = User.find_by_name(params[:contract][:buyer])
    if @contract.save
      redirect_to @contract
    else
      render :new
    end
  end
end
