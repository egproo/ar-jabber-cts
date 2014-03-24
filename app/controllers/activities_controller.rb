class ActivitiesController < ApplicationController
  def index
    @activities = Audited::Adapters::ActiveRecord::Audit.includes(:user, :auditable).order(created_at: :desc).limit(200)
  end
end
