class RootController < ApplicationController
  def index
    @contracts = Contract.all.map do |contract|
      last_payment = contract.payments.last
      {
        room_name: contract.name,
        room_owner: contract.buyer,
        contract_creator: contract.seller,
        owner_number: contract.buyer.try(:phone),
        first_appeared: contract.created_at,
        contract_period: contract.duration_months,
        payment_amount: last_payment.try(:amount),
        payment_date: last_payment.try(:created_at),
        next_payment_date: last_payment.try(:created_at).try(:+, contract.duration_months.months),
        next_payment_estimate: contract.next_amount_estimate,
      }
    end
    respond_to do |format|
      format.json { render json: @contracts }
      format.xml { render xml: @contracts }
      format.html
    end
  end
end
