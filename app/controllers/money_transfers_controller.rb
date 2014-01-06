class MoneyTransfersController < ApplicationController
  def new
    @money_transfer = MoneyTransfer.new
    # FIXME: security issue (minor: r/o access)
    @money_transfer.sender = User.find(params[:sender_id]) if params[:sender_id]
    @money_transfer.receiver = User.find(params[:receiver_id]) if params[:receiver_id]

    if @money_transfer.sender && @money_transfer.receiver
      @contracts = Contract.all(conditions: {
        buyer_id: @money_transfer.sender,
        seller_id: @money_transfer.receiver,
      })
    else
      @contracts = []
    end
  end

  def create
    @money_transfer = MoneyTransfer.new(
      amount: params[:money_transfer][:amount],
      comment: params[:money_transfer][:comment],
    )

    @money_transfer.sender = User.find_by_name(params[:money_transfer][:sender])
    @money_transfer.receiver = User.find_by_name(params[:money_transfer][:receiver])

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
  end
end
