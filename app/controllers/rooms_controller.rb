class RoomsController < ApplicationController
  def index
    @server_rooms = Ejabberd.new.rooms.map do |r|
      {
        name: "#{r['room']}@#{r['host']}",
        num_participants: r['num_participants'],
        last_message_at: r['last_message_at'],
      }
    end
    @rooms = Room.where("(active = ?) OR (active = ? AND deactivated_at > ?)", true, false, 3.days.ago).
             preload(:last_payment).sold_by(current_user).includes(:buyer, :seller)
    @rooms.each do |r|
      if sr = @server_rooms.find { |sr| sr[:name] == r.name }
        r.instance_variable_set(:@occupants_number, sr[:num_participants])
        r.instance_variable_set(:@last_message_at, sr[:last_message_at])
      else
        r.instance_variable_set(:@occupants_number, -1)
        r.instance_variable_set(:@last_message_at, 'RNE')
      end
    end
  end

  def show
    @room = Room.find(params[:id])
    @room_info = Ejabberd.new.room(@room.name).info
  end

  def edit
    @room = Room.find(params[:id])
    @room.name.sub!("@#{Ejabberd::DEFAULT_ROOMS_VHOST}", '')
    @room.payments.build(money_transfer: MoneyTransfer.new(received_at: Time.now.to_date))
  end

  def update
    @room = Room.find(params[:id])

    if params[:room][:buyer_attributes][:name] != @room.buyer.name
      logger.info('Room is changing buyer')
      old_room = @room
      old_room.deactivate(false)
      @room = new_or_existing_room(params[:room])
    else
      @room.comment = params[:room][:comment]
    end

    begin
      @room.transaction do
        old_room.save! if old_room
        @room.save!
      end
      if request.xhr?
        render status: 200, json: { location: Rails.application.routes.url_helpers.room_path(@room) }
      else
        redirect_to @room
      end
    rescue
      render text: 'ERROR' # FIXME: render form with errors
      #@room.id = old_room.id if old_room
      #@room.name.sub!('@conference.syriatalk.biz', '')
      #render :new, status: 400, layout: !request.xhr?
    end
  end

  def new
    @room = Room.new
    @room.buyer = User.new
    @room.seller = current_user
    @room.payments.build(money_transfer: MoneyTransfer.new(received_at: Time.now.to_date))
  end

  def create
    @room = new_or_existing_room(params[:room])

    if success = @room.save
      Ejabberd.new.room(@room.name).create(@room.buyer.jid)
    else
      @room.name.sub!("@#{Ejabberd::DEFAULT_ROOMS_VHOST}", '')
    end

    render_ajax_form(@room, success)
  end

  def destroy
    Room.active.find(params[:id]).deactivate.save!
    render :index
  end

  private
  def new_or_existing_room(attrs)
    room = Room.new(
      name: attrs[:name],
      active: true,
      comment: attrs[:comment],
    )

    room.name += "@#{Ejabberd::DEFAULT_ROOMS_VHOST}" unless room.name.include?('@')
    room.seller = current_user
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
      room.seller = current_user
      room.active = true
      room.comment = attrs[:comment] || room.comment
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
