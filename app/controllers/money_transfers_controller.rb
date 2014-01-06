class MoneyTransfersController < ApplicationController
  def new
    @money_transfer = MoneyTransfer.new
    # FIXME: security issue (minor: r/o access)
    @money_transfer.sender = User.find(params[:sender_id]) if params[:sender_id]
    @money_transfer.receiver = User.find(params[:receiver_id]) if params[:receiver_id]
  end

  def create
  end
end
