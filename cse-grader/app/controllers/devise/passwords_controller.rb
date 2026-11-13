class Devise::PasswordsController < Devise::PasswordsController
  # Override the create action to show reset link in development
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      if Rails.env.development?
        # In development, show the reset link directly
        redirect_to password_reset_development_path(reset_password_token: resource.reset_password_token), 
                    notice: "Password reset link generated! Check the page for your reset link."
      else
        respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
      end
    else
      respond_with(resource)
    end
  end

  # Development helper to show reset link
  def development_reset
    @reset_password_token = params[:reset_password_token]
    @reset_url = edit_user_password_url(reset_password_token: @reset_password_token)
  end

  private

  def after_sending_reset_password_instructions_path_for(resource_name)
    new_session_path(resource_name) if is_navigational_format?
  end
end
