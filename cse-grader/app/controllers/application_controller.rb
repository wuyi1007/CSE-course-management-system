class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Expose role helpers so views/layouts can toggle UI based on the signed-in user
  helper_method :current_student?, :current_instructor?, :current_admin?

  # Redirect users by role after sign-in
  def after_sign_in_path_for(user)
    if !user.approved?
      sign_out(user)
      set_flash_message!(:alert, :not_approved)
      new_user_session_path
    elsif user.admin?
      admin_dashboard_path   # you’ll make this view next
    else
      catalog_index_path           # open course catalog
    end
  end

  # After any sign up (no catalog redirect)
  def after_sign_up_path_for(resource)
    sign_out resource if user_signed_in?
    flash.delete(:notice)
    set_flash_message!(:alert, :not_approved)
    new_user_session_path
  end

  # Authorization checks for different views
  def require_role!(*roles)
    authenticate_user!
    return if roles.any? { |role| current_user&.public_send("#{role}?") }

    redirect_to root_path, alert: "You do not have access to that page."
  end

  def current_student?
    user_signed_in? && current_user.student?
  end

  def current_instructor?
    user_signed_in? && current_user.instructor?
  end

  def current_admin?
    user_signed_in? && current_user.admin?
  end
  
  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [:role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role])
  end
end
