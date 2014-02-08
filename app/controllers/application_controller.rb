class ApplicationController < ActionController::Base
  protect_from_forgery
  include PublicActivity::StoreController

  before_filter :set_locale

  def set_locale
    I18n.locale = current_user.locale
  rescue => e
    logger.error("#{e.inspect}\n#{e.backtrace*$/}")
    render text: "No current user: #{e}"
  end

  def current_user
    @current_user ||=
      begin
        @current_user_name ||= ActionController::HttpAuthentication::Basic::user_name_and_password(request).first rescue nil
        User.find_by_name(@current_user_name || (Rails.env.development? && User::STUB_NAME))
      end
  end

  protected
  def render_ajax_form(object, success)
    if success
      if request.xhr?
        # FIXME: use Rails.application.routes.url_helpers
        render status: 200, json: { location: "/#{object.class.name.pluralize.underscore}/#{object.id}" }
      else
        redirect_to object
      end
    else
      render (object.new_record? ? :new : :edit), status: 400, layout: !request.xhr?
    end
  end

  helper_method :current_user
end
