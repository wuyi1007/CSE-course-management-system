class ProfilesController < ApplicationController
  # Profile page is available to any approved, authenticated user role
  before_action -> { require_role!(:student, :instructor, :admin) }

  def show
  end

  def update
    # Devise helper handles validation of current password before setting a new one
    if current_user.update_with_password(profile_params)
      bypass_sign_in(current_user)
      redirect_to profile_path, notice: "Password changed."
    else
      flash.now[:alert] = "Can't change password"
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
