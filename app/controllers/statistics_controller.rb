class StatisticsController < ApplicationController
  def income
    @income = MoneyTransfer.all(order: 'received_at ASC').each_with_object(Hash.new(0)) do |mt, chart|
      chart[mt.received_at.to_date.to_datetime.to_i * 1000] += mt.amount
    end
  end
end
