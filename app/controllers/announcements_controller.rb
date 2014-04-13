class AnnouncementsController < ApplicationController
  load_and_authorize_resource except: :create

  def new
    @announcement.buyer = User.new
    @announcement.seller = current_user
    @announcement.payments.build(
      money_transfer: MoneyTransfer.new(received_at: Time.now.to_date),
      amount: Announcement::DEFAULT_COST,
    )
  end
  
  def create
    attrs = params[:announcement]
    @announcement = Announcement.new(
      name: attrs[:name],
      active: true,
      adhoc_data: attrs[:adhoc_data],
      comment: attrs[:comment],
    )

    @announcement.seller = current_user
    @announcement.buyer = User.find_by_jid(attrs[:buyer_attributes][:jid]) ||
                 User.new(attrs[:buyer_attributes].merge(role: User::ROLE_CLIENT))

    payment_hash = attrs[:payment_attributes]
    money_transfer = MoneyTransfer.new(
      sender: @announcement.buyer,
      receiver: @announcement.seller,
      amount: payment_hash[:amount],
      received_at: payment_hash[:money_transfer_attributes][:received_at],
    )
    payment = money_transfer.payments.build(
      contract: @announcement,
      amount: money_transfer.amount,
      effective_months: 1,
    )

    @announcement.payments << payment

    authorize! :create, @announcement

    if success = @announcement.save
      receivers = Ejabberd.new.announce(@announcement.name, @announcement.adhoc_data)
      flash[:notice] = "The announcement has been sent to #{receivers} users."
    else
      logger.error @announcement.errors.full_messages
    end

    render_ajax_form(@announcement, success)
  end

  def show
  end

  def index
    @announcements = @announcements.includes(:seller, :buyer)
    if params[:untracked]
      @announcements = @announcements.untracked(current_user)
    end
  end
end
