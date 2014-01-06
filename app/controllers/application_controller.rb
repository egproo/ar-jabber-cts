class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  def set_locale
    I18n.locale = current_user.locale
  rescue
    render text: 'No current user'
  end

  def current_user
    @current_user ||=
      begin
        @current_user_name ||= ActionController::HttpAuthentication::Basic::user_name_and_password(request).first rescue nil
        User.first(conditions: { name: [@current_user_name, 'stub'] })
      end
  end
end
