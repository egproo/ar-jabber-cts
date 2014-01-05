class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  def set_locale
    I18n.locale = current_user.locale
  end

  def current_user
    User.all(conditions: { role: [User::ROLE_ADMIN, User::ROLE_SUPER_MANAGER] }).sample
  end
end
