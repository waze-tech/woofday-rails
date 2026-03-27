class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
    @preset_role = params[:role]
    @plan = params[:plan]
  end

  def create
    @user = User.new(user_params)
    @plan = params[:plan]

    if @user.save
      start_new_session_for(@user)
      
      # Store the selected plan for after setup completion
      if @user.pro? && @plan == "pro"
        session[:selected_plan] = "pro"
      end
      
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
