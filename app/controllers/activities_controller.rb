class ActivitiesController < ApplicationController
  def index
    @activities = Audited::Adapters::ActiveRecord::Audit.includes(:user, :auditable).all
  end
end
