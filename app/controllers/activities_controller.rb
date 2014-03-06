class ActivitiesController < ApplicationController
  def index
    @activities = Audited::Adapters::ActiveRecord::Audit.includes(:user).all
  end
end
