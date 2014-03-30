class EjabberdController < ApplicationController
  skip_before_filter :authenticate_user!, only: :report

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
    Thread.new do
      logger.info "COMMITTING TRANSACTION: #{ts}"
      ej.apply_transactions ts
    end
    flash[:notice] = 'Commit is in progress. Please refresh this page in a few minutes'
    redirect_to :ejabberd_sync
  end

  def report
    convert_strings = lambda do |x|
      return x unless Array === x
      begin
        x.pack('U*')
      rescue
        mapped = x.map { |e| convert_strings.call(e) }
        if mapped.size == 1 && Array === mapped[0]
          mapped[0]
        else
          mapped
        end
      end
    end

    report = convert_strings.call(BERT.decode(request.raw_post))

    if report.assoc(:auth).try(:last) != 'gn9378rymx48uh2894'
      return render text: 'Unauthorized'
    end

    sender = report.assoc(:from).last
    packet = report.assoc(:packet).last
    elements = Hash[packet[3].map do |_xmlelement, name, _empty_string, (_xmlcdata, value)|
      [name, value]
    end]

    logger.info("
      SENDER: #{sender}
      SUBJECT: #{elements['subject']}
      BODY: #{elements['body']}
    ")

    render text: 'Accepted'
  end
end
