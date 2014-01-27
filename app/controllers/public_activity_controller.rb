class PublicActivityController < ApplicationController
  def index
    respond_to do |format|
      format.js {
        @public_activity =
          fetch_activity_for_model('Payment', [:contract, :money_transfer]).concat(
          fetch_activity_for_model('User').concat(
          fetch_activity_for_model('MoneyTransfer', [:sender, :receiver]).concat(
          fetch_activity_for_model('Contract')
        )))
      }
      format.html
    end
  end

  private
  def fetch_activity_for_model(model, includes = [])
    PublicActivity::Activity.all(
      conditions: ['trackable_type = ? AND created_at > ?', model, 1.month.ago],
      include: [
        :owner,
        :trackable => includes,
      ])
  end
end
