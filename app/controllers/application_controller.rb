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
        User.find_by_name(@current_user_name) ||
          (Rails.env.development? && User.find_by_name(User::STUB_NAME))
      end
  end

  helper_method :current_user
end
