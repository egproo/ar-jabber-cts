class PublicActivityController < ApplicationController
  def index
    @public_activity = Audited::Adapters::ActiveRecord::Audit.includes(:user).all.map do |r|
      {
        action: r.action,
        auditable_type: r.auditable_type,
        auditable_path: "/#{r.auditable_type.pluralize.underscore}/#{r.auditable_id}", # Fixme: use routes?
        user: r.user.try(:name) || 'Rails Console',
        changes: r.audited_changes.map { |column, changes|
          "#{column} " << if Array === changes
                            old, new = changes
                            "#{old} => #{new}"
                          else
                            changes.to_s
                          end
        }.join($/),
        created_at: r.created_at,
      }
    end
  end
end
