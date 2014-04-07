class ActivitiesController < ApplicationController
  load_and_authorize_resource :activity, class: 'Audited::Adapters::ActiveRecord::Audit'

  def index
    @activities = @activities.includes(:user, :auditable).order('created_at DESC').limit(200)
  end
end
