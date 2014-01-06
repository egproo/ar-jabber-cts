class MoneyTransfersController < ApplicationController
  def new
    @money_transfer = MoneyTransfer.new
    # FIXME: security issue (minor: r/o access)
    @money_transfer.sender = User.find(params[:sender_id]) if params[:sender_id]
    @money_transfer.receiver = User.find(params[:receiver_id]) if params[:receiver_id]

    @contracts = money_transfer_contracts(@money_transfer)
  end

  def create
    @money_transfer = MoneyTransfer.new(
      amount: params[:money_transfer][:amount],
      comment: params[:money_transfer][:comment],
    )

    @money_transfer.sender = User.find_by_name(params[:money_transfer][:sender])
    @money_transfer.receiver = User.find_by_name(params[:money_transfer][:receiver])

    @contracts = money_transfer_contracts(@money_transfer)
    
    @contracts.each do |contract|
      if amount = params["pay_contract_#{contract.id}"]
        @money_transfer.payments.build(
          amount: amount
        ).contract = contract
      end
    end

    if @money_transfer.save
      redirect_to @money_transfer
    else
      render :new
    end
  end

  def show
    @money_transfer = MoneyTransfer.find(params[:id])
  end

  def index
    # FIXME: security issue (full read: major)
    @money_transfers = MoneyTransfer.all
    respond_to do |format|
      format.html
      format.json { render json: @money_transfers }
    end
  end

  private
  def money_transfer_contracts(mt)
    if mt.sender && mt.receiver
      Contract.all(conditions: {
        buyer_id: mt.sender,
        seller_id: mt.receiver,
      })
    else
      []
    end
  end
end
