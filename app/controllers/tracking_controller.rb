class TrackingController < ApplicationController
  def index
    contracts = {
      aaData:
        Contract.all(include: [:buyer, :seller, :payments]).map do |contract|
          [
            contract.name,
            contract.buyer,
            contract.seller,
            contract.created_at,
            contract.duration_months,
            contract.last_payment.try(:amount),
            contract.last_payment.try(:created_at),
            contract.next_payment_date,
            contract.next_amount_estimate,
          ]
        end
    }
    respond_to do |format|
      format.json { render json: contracts }
      format.xml { render xml: contracts }
      format.html
    end
  end
end
