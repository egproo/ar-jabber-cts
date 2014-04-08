class EjabberdController < ApplicationController
  skip_before_filter :authenticate_user!, only: :report
  skip_authorization_check

  def sync
    return render text: 'Not allowed' unless current_user.role >= User::ROLE_SUPER_MANAGER
    @transactions = Ejabberd.new.build_transactions.map { |action, name, reason, object|
      ["#{name} #{action} (#{reason})", object, name]
    }
  end

  def commit
    return render text: 'Not allowed' unless current_user.role >= User::ROLE_SUPER_MANAGER
    ej = Ejabberd.new
    ts = ej.build_transactions
    logger.info "COMMITTING TRANSACTION: #{ts}"
    ej.apply_transactions ts
    redirect_to :ejabberd_sync
  end

  def report
    convert_strings = lambda do |x|
      return x unless Array === x
      begin
        x.pack('U*')
      rescue
        x.map { |e| convert_strings.call(e) }
      end
    end

    report = convert_strings.call(BERT.decode(request.raw_post))
    logger.debug("Report received: #{report}")

    if report.assoc(:auth).try(:last) != Ejabberd::CONFIG[:auth_code]
      return render text: 'Unauthorized'
    end

    sender = report.assoc(:from).last
    packet = report.assoc(:packet).last
    type = report.assoc(:type).last
    elements = Hash[packet[3].map do |_xmlelement, name, _attrs, ((_xmlcdata, value))|
      [
        name,
        (value.encode(Encoding::ISO_8859_1).force_encoding(Encoding::UTF_8) rescue value)
      ]
    end]

    logger.info("
      TYPE: #{type}
      SENDER: #{sender}
      SUBJECT: #{elements['subject']}
      BODY: #{elements['body']}
    ")

    if sender = User.find_by_jid(sender.split('/', 2)[0])
      if sender.role >= User::ROLE_MINI_MANAGER
        a = Announcement.new(
          adhoc_data: elements['body'],
          name: elements['subject'] || 'no subject',
        )
        a.seller = sender
        a.buyer = sender
        a.active = false
        if a.save
          render text: "queued (id #{a.id})"
        else
          render text: a.errors.full_messages.join($/), status: 400
        end
      else
        render text: 'not enough privileges', status: 403
      end
    else
      render text: 'user not found', status: 403
    end
  end
end
