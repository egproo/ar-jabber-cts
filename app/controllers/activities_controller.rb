class ActivitiesController < ApplicationController
  def index
    @activities = Audited::Adapters::ActiveRecord::Audit.includes(:user).all.map do |r|
      {
        action: r.action,
        associated_id: r.associated_id,
        associated_type: r.associated_type,
        auditable_id: r.auditable_id,
        auditable_type: r.auditable_type,
        auditable: r.auditable,
        user: r.user.try(:name) || 'Rails Console',
        audited_changes: r.audited_changes.reject { |k| k == "adhoc_data" || k == "encrypted_password" },
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
