class MoneyTransfersController < ApplicationController
  load_and_authorize_resource except: [:create, :update]

  def new
    @money_transfer.received_at = Time.now.to_date
    # FIXME: security issue (minor: r/o access)
    @money_transfer.sender = User.find(params[:sender_id]) if params[:sender_id]
    @money_transfer.receiver = User.find(params[:receiver_id]) if params[:receiver_id]

    @highlight_contract_id = params[:contract_id].try(:to_i)
    fill_payments(@money_transfer)
    sort_payments(@money_transfer)
  end

  def create
    @money_transfer = MoneyTransfer.new(
      amount: params[:money_transfer][:amount],
      comment: params[:money_transfer][:comment],
      received_at: params[:money_transfer][:received_at],
    )

    @money_transfer.sender = User.find_by_name(params[:money_transfer][:sender])
    @money_transfer.receiver = User.find_by_name(params[:money_transfer][:receiver])

    params[:money_transfer][:payments_attributes].each_value do |payment_hash|
      next if payment_hash[:amount].blank?

      if contract = Contract.first(conditions: {
            buyer_id: @money_transfer.sender,
            seller_id: @money_transfer.receiver,
            id: payment_hash[:contract_attributes][:id],
          })
        payment = @money_transfer.payments.build(
          contract: contract,
          amount: payment_hash[:amount],
          effective_months: payment_hash[:effective_months],
        )
      end
    end

    authorize! :create, @money_transfer

    if @money_transfer.save
      redirect_to @money_transfer
    else
      logger.debug "Validation errors: #{@money_transfer.errors.inspect}"
      fill_payments(@money_transfer)
      sort_payments(@money_transfer)
      render :new
    end
  end

  def show
  end

  def edit
    @money_transfer.received_at = @money_transfer.received_at.to_date
    sort_payments(@money_transfer)
  end

  def update
    @money_transfer = MoneyTransfer.find(params[:id], include: { payments: :contract })

    @money_transfer.assign_attributes(
      amount: params[:money_transfer][:amount],
      comment: params[:money_transfer][:comment],
      received_at: params[:money_transfer][:received_at],
    )

    @money_transfer.payments.each do |p|
      index, payment_hash = params[:money_transfer][:payments_attributes].find do |index, payment_hash|
        payment_hash[:id].to_i == p.id
      end
      next unless payment_hash

      p.effective_months = payment_hash[:effective_months]
      p.amount = payment_hash[:amount]
    end

    authorize! :edit, @money_transfer

    if @money_transfer.save
      redirect_to @money_transfer
    else
      logger.debug "Validation errors: #{@money_transfer.errors.inspect}"
      render :edit
    end
  end

  def index
    # FIXME: security issue (full read: major)
    @money_transfers = @money_transfers.includes(:sender, :receiver)
  end

  private
  def fill_payments(mt)
    return unless mt.sender && mt.receiver

    conditions = {
      buyer_id: mt.sender,
      active: true,
    }

    conditions[:seller_id] = mt.receiver unless current_user.role >= User::ROLE_SUPER_MANAGER

    Room.where(conditions).each do |contract|
      unless mt.payments.index { |x| x.contract == contract }
        mt.payments.build(contract: contract)
      end
    end
  end

  def sort_payments(mt)
    mt.payments.sort! do |p1, p2|
      PreferenceArrayComparator.compare(
        payment_preference_values_array(p1),
        payment_preference_values_array(p2),
      )
    end
  end

  def payment_preference_values_array(p)
    [
      p.contract.id == @highlight_contract_id,
      p.errors.any?,
      !!p.amount,
      p.contract.next_payment_date,
    ]
  end
end
