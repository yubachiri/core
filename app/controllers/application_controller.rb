class ApplicationController < ActionController::Base
  require 'active_support'
  require 'active_support/core_ext/date/calculations'

  include Pundit
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Punditエラー時処理

  rescue_from NotAuthorizedError, with: :render_404

  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
    end

    render file: "#{Rails.root}/public/404.html", status: 404, content_type: 'text/html'
  end

  protected
  # Deviseのstrong parameters
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

end
