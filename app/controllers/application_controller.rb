class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization unless: :devise_controller?

  before_filter :set_locale, :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    logger.error exception.inspect + exception.backtrace * $/
    render text: exception.message
  end

  def set_locale
    I18n.locale = current_user.locale if current_user
  end

  protected
  alias_method :real_user, :current_user
  helper_method :real_user
  def current_user
    @effective_user ||=
      real_user &&
      if real_user.role >= User::ROLE_SUPER_MANAGER &&
          effective_user_id = session[:effective_user_id]
        # Allow super-manager to switch effective user
        User.find(effective_user_id)
      else
        real_user
      end
  end

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

  private 

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

end
