class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
    @preset_role = params[:role]
    @plan = params[:plan]
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for(@user)
      redirect_after_signup
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def redirect_after_signup
      if @user.pro?
        redirect_to pros_setup_path, notice: "Let's set up your professional profile!"
      else
        redirect_to root_path, notice: "Welcome to woof.day!"
      end
    end

    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation, :role)
    end
end
