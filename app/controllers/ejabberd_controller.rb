class EjabberdController < ApplicationController
  def sync
    @transactions = Ejabberd.new.build_transactions.map { |action, name, reason, object|
      ["#{name} #{action} (#{reason})", object]
    }
  end

  def commit
    ej = Ejabberd.new
    ej.apply_transactions ej.build_transactions
    redirect_to :ejabberd_sync
  end
end
