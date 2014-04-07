class StatisticsController < ApplicationController
  skip_authorization_check

  def income
    @income = MoneyTransfer.all(order: 'received_at ASC').each_with_object(Hash.new(0)) do |mt, chart|
      chart[mt.received_at.to_date] += mt.amount
    end
  end
end
