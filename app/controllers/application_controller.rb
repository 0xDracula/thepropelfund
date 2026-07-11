class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_identity

  private

  def current_identity
    return nil unless session[:identity]

    @current_identity ||= Identity.new(**session[:identity].symbolize_keys)
  end

  def require_identity
    return if current_identity

    redirect_to login_path, alert: "Sign in to continue"
  end
end
