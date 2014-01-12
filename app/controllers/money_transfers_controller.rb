class MoneyTransfersController < ApplicationController
  def new
    @money_transfer = MoneyTransfer.new
    @money_transfer.received_at = Time.now.to_date
    # FIXME: security issue (minor: r/o access)
    @money_transfer.sender = User.find(params[:sender_id]) if params[:sender_id]
    @money_transfer.receiver = User.find(params[:receiver_id]) if params[:receiver_id]

    @contracts = money_transfer_contracts(@money_transfer).sort do |c1, c2|
      if c1.next_payment_date && c2.next_payment_date
        c1.next_payment_date <=> c2.next_payment_date
      else
        if c1.next_payment_date
          1
        elsif c2.next_payment_date
          -1
        else
          0
        end
      end
    end

    if @highlight_contract_id = params[:contract_id]
      @highlight_contract_id = @highlight_contract_id.to_i
      highlight_contract = @contracts.find { |c| c.id == @highlight_contract_id }
      @contracts.delete(highlight_contract)
      @contracts.unshift(highlight_contract)
    end
  end

  def create
    @money_transfer = MoneyTransfer.new(
      amount: params[:money_transfer][:amount],
      comment: params[:money_transfer][:comment],
      received_at: params[:money_transfer][:received_at],
    )

    @money_transfer.sender = User.find_by_name(params[:money_transfer][:sender])
    @money_transfer.receiver = User.find_by_name(params[:money_transfer][:receiver])

    @contracts = money_transfer_contracts(@money_transfer)
    
    @contracts.each do |contract|
      if (amount = params["amount_contract_#{contract.id}"]).present?
        @money_transfer.payments.build(
          amount: amount
        ).tap { |mt|
          mt.contract = contract
          mt.created_at = @money_transfer.created_at
        }

        duration = params["duration_contract_#{contract.id}"].to_i
        unless (1..12).include?(duration)
          flash[:error] = "Invalid value or duration of contract #{contract.name}: #{duration}"
          return render :new
        end
      end
    end

    begin
      MoneyTransfer.transaction do
        @money_transfer.payments.each do |p|
          p.contract.update_attributes!(duration_months: params["duration_contract_#{p.contract.id}"])
        end
        @money_transfer.save!
        redirect_to @money_transfer
      end
    rescue
      render :new
    end
  end

  def show
    @money_transfer = MoneyTransfer.find(params[:id])
  end

  def index
    # FIXME: security issue (full read: major)
    @money_transfers = MoneyTransfer.all(include: [:sender, :receiver])
    respond_to do |format|
      format.html
      format.json { render json: @money_transfers }
      format.datatable { render text: ({ aaData: @money_transfers }).to_json(include: [:sender, :receiver]) }
    end
  end

  private
  def money_transfer_contracts(mt)
    if mt.sender && mt.receiver
      conditions = { buyer_id: mt.sender }
      if current_user.role < User::ROLE_SUPER_MANAGER
        conditions[:seller_id] = mt.receiver
      end
      Contract.all(conditions: conditions, include: :last_payment)
    else
      []
    end
  end
end
