class EjabberdController < ApplicationController
  skip_before_filter :authenticate_user!, only: :report
  skip_authorization_check

  def sync
    return render text: 'Not allowed' unless current_user.role >= User::ROLE_SUPER_MANAGER
    @transactions = Ejabberd.new.build_transactions.map { |action, name, reason, object|
      ["#{name} #{action} (#{reason})", object, name]
    }
  end

  def s2s
    return render text: 'Not allowed' unless current_user.role >= User::ROLE_SUPER_MANAGER
    ejabberd = Ejabberd.new
    if params[:vhost] && params[:server] && params[:operation]
      @result = ejabberd.rpc(:s2s_filter,
                             # ejabberd xmlrpc is order-sensitive so we have to re-specify params
                             vhost: params[:vhost],
                             server: params[:server],
                             action: params[:operation])
      @result = %w(failure success)[@result] if Integer === @result
    end
    @actions = ejabberd.rpc(:s2s_filter,
                            vhost: Ejabberd::DEFAULT_VHOST,
                            server: '@all',
                            action: 'query')
    @default_policy = ejabberd.rpc(:s2s_filter,
                                   vhost: Ejabberd::DEFAULT_VHOST,
                                   server: '@default',
                                   action: 'query')
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
      return render status: 403, text: 'Unauthorized'
    end

    if report.assoc(:type).last == 'register'
      user = report.assoc(:user).last
      server = report.assoc(:server).last
      password = report.assoc(:password).last

      recent = recents(user)
      user_nd = user.gsub(/\d/, '')
      if recent.any? { |r| r.gsub(/\d/, '') == user_nd }
        logger.info("Register Inhibited: #{user}@#{server}:#{password} (#{user_nd})")
        password = 'registration-inhibited'
      else
        logger.info("Register Allowed for #{user}@#{server}")
      end

      return render text: password
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
        a.active = false
        if a.autotrack && a.save
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

  private
  def recents(add = nil)
    File.open('/tmp/ejabberd-recent-regs.txt', 'a+') do |f|
      f.flock(File::LOCK_EX)

      f.seek(0)
      regs = f.read.split("\n")

      if regs.size > 100
        regs = regs[-100..-1]
      end

      f.seek(0)
      f.truncate(0)

      f.puts regs
      f.puts add if add
      regs
    end
  end
end
