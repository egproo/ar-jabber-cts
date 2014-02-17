class EjabberdController < ApplicationController
  def sync
    @transactions = Ejabberd.new.build_transactions.map { |action, name, reason, object|
      ["#{name} #{action} (#{reason})", object]
    }
  end

  def commit
    ej = Ejabberd.new
    ts = ej.build_transactions
    logger.info "COMMITTING TRANSACTION: #{ts}"
    ej.apply_transactions ts
    redirect_to :ejabberd_sync
  end
end
