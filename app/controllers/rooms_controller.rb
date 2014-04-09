class RoomsController < ApplicationController
  load_and_authorize_resource except: :create

  def index
    @rooms = @rooms.where("(active = ?) OR (active = ? AND deactivated_at > ? AND deactivated_by != ?)",
                                     true,           false,                 3.days.ago,             'seller')

    respond_to do |format|
      format.html { @rooms = @rooms.preload(:last_payment).includes(:buyer, :seller) }
      format.json {
        server_rooms = Ejabberd.new.rooms.map do |r|
          {
            name: "#{r['room']}@#{r['host']}",
            num_participants: r['num_participants'],
            last_message_at: r['last_message_at'],
          }
        end

        render json: (@rooms.each_with_object({}) do |room, rooms|
          if sr = server_rooms.find { |sr| sr[:name] == room.name }
            rooms[room.id] = {
              num_participants: sr[:num_participants],
              last_message_at: (Time.parse("#{sr[:last_message_at]} +0000").to_i rescue 0),
            }
          end
        end)
      }
    end
  end

  def show
    @room_info = Ejabberd.new.room(@room.name).info
  end

  def untracked
    @room_name = params[:name]
    @room_info = Ejabberd.new.room(@room_name).info
  end

  def backup_view
    @room_info = @room.adhoc_data
  end

  def edit
    @room.payments.build(money_transfer: MoneyTransfer.new(received_at: Time.now.to_date))
  end

  def update
    if params[:room][:buyer_attributes][:name] != @room.buyer.name
      logger.info('Room is changing buyer')
      old_room = @room
      old_room.deactivate(server_destroy: false,
                          deactivated_by: (current_user == old_room.seller ? 'seller' : 'manager'))
      @room = new_or_existing_room(params[:room])
    else
      @room.comment = params[:room][:comment]

      # FIXME(artem): 2014-04-07: duplicated code
      if (new_seller_name = params[:room][:seller_attributes][:name]) != @room.seller.name
        raise CanCan::AccessDenied.new('Not allowed to change seller', :update, Room) unless current_user.role >= User::ROLE_SUPER_MANAGER
        @room.seller = User.find_by_name(new_seller_name)
      end
    end

    begin
      @room.transaction do
        old_room.save! if old_room
        @room.save!
      end
      # if the room has been transfered after being destroyed, we need to re-create it
      # NOTE: should not happen, because only destroyed rooms are disabled,
      #       and disabled room does not have 'edit' button for transfer.
      Ejabberd.new.room(@room.name).create(@room.buyer.jid)
      if request.xhr?
        render status: 200, json: { location: Rails.application.routes.url_helpers.room_path(@room) }
      else
        redirect_to @room
      end
    rescue
      render text: 'ERROR' # FIXME: render form with errors
    end
  end

  def new
    @room.buyer = User.new
    @room.seller = current_user
    @room.payments.build(money_transfer: MoneyTransfer.new(received_at: Time.now.to_date))
  end

  def create
    @room = new_or_existing_room(params[:room])
    authorize! :create, @room

    if success = @room.save
      Ejabberd.new.room(@room.name).create(@room.buyer.jid)
    end

    render_ajax_form(@room, success)
  end

  def destroy
    if @room.active
      @room.deactivate(deactivated_by: (@room.seller == current_user ? 'seller' : 'manager')).save!
    end
    redirect_to action: :index
  end

  def store_adhoc_data
    @room.backup!
    @room.save!
    redirect_to @room
  end

  private
  def new_or_existing_room(attrs)
    room = Room.new
    room.short_name = attrs[:short_name]

    # FIXME(artem): 2014-04-07: can? :create, user
    room.buyer = User.find_by_name(attrs[:buyer_attributes][:name]) ||
                 User.new(attrs[:buyer_attributes].merge(role: User::ROLE_CLIENT))

    if existing_room = Room.first(
          conditions: {
            name: room.name,
            buyer_id: room.buyer,
            active: false,
          })
      logger.info("Existing room #{existing_room.id} found for this buyer")
      room = existing_room
    end

    room.active = true
    room.comment = attrs[:comment] if attrs[:comment].present?
    room.seller = current_user
    if (new_seller_name = attrs[:seller_attributes][:name]) != room.seller.name
      raise CanCan::AccessDenied.new('Not allowed to change seller', :update, Room) unless current_user.role >= User::ROLE_SUPER_MANAGER
      room.seller = User.find_by_name(new_seller_name)
    end

    payment_hash = attrs[:payment_attributes]
    money_transfer = MoneyTransfer.new(
      sender: room.buyer,
      receiver: room.seller,
      amount: payment_hash[:amount],
      received_at: payment_hash[:money_transfer_attributes][:received_at],
    )
    payment = money_transfer.payments.build(
      contract: room,
      amount: money_transfer.amount,
      effective_months: payment_hash[:effective_months]
    )

    room.payments << payment

    room
  end
end
