class ActivitiesController < ApplicationController
  def index
    @activities = Audited::Adapters::ActiveRecord::Audit.includes(:user).all.map do |r|
      {
        action: r.action,
        associated_id: r.associated_id,
        associated_type: r.associated_type,
        auditable_id: r.auditable_id,
        auditable_type: r.auditable_type,
        audited_changes: {
          name: r.audited_changes['name'],
          jid: r.audited_changes['jid'],
          phone: r.audited_changes['phone'],
          buyer_id: r.audited_changes['buyer_id'],
          seller_id: r.audited_changes['seller_id'],
          next_amount_estimate: r.audited_changes['next_amount_estimate'],
          active: r.audited_changes['active'],
          sender_id: r.audited_changes['sender_id'],
          receiver_id: r.audited_changes['receiver_id'],
          amount: r.audited_changes['amount'],
          received_at: r.audited_changes['received_at'],
          #sender: User.find(r.audited_changes['sender_id']),
          #receiver: User.find(r.audited_changes['receiver_id']),
        },
        comment: r.comment,
        created_at: r.created_at,
        id: r.id,
        user_id: r.user_id,
        user_type: r.user_type,
        username: r.username,
        version: r.version
      }
    end
  end
end
