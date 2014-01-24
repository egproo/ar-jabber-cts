class PublicActivityController < ApplicationController
  def index
    public_activities =
      PublicActivity::Activity.all(
        conditions: { trackable_type: 'Payment' },
        include: [
          :owner,
          :trackable => [:contract, :money_transfer],
        ]) +
      PublicActivity::Activity.all(
        conditions: { trackable_type: 'User' },
        include: [
          :owner,
          :trackable,
        ]) +
      PublicActivity::Activity.all(
        conditions: { trackable_type: 'MoneyTransfer' },
        include: [
          :owner,
          :trackable => [:sender, :receiver],
        ]) +
      PublicActivity::Activity.all(
        conditions: { trackable_type: 'Contract' },
        include: [
          :owner,
          :trackable,
        ])
    respond_to do |format|
      format.html
      format.datatable {
        render json: {
          aaData: public_activities
        },
        include: [
          { owner: { except: [:password] } },
          { trackable: { except: [:password], methods: [:to_s]  } },
        ]
      }
    end
  end
end
