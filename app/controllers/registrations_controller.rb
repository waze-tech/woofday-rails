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
      redirect_after_signup
    else
      # Preserve form state for validation errors
      @preset_role = @user.role
      render :new, status: :unprocessable_entity
    end
  end

  private

    def redirect_after_signup
      if @user.pro?
        # Create pro profile stub immediately
        @user.create_pro_profile!(setup_step: 1) unless @user.pro_profile
        
        if @plan == "pro"
          # Pro plan: payment first, then profile setup
          redirect_to_stripe_checkout
        else
          # Free plan: straight to profile setup
          redirect_to pros_setup_path, notice: "Let's set up your professional profile!"
        end
      else
        redirect_to root_path, notice: "Welcome to woof.day!"
      end
    end
    
    def redirect_to_stripe_checkout
      pro_profile = @user.pro_profile
      service = StripeCheckoutService.new(pro_profile)
      
      checkout_session = service.create_subscription_checkout(
        success_url: pros_setup_url(subscription: "success"),
        cancel_url: pricing_url
      )
      
      # Store the URL and redirect via an intermediate page (Turbo can't follow external redirects)
      session[:stripe_checkout_url] = checkout_session.url
      redirect_to stripe_redirect_path
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe checkout error: #{e.message}"
      redirect_to pros_setup_path, alert: "Payment setup failed. You can upgrade later from your dashboard."
    end

    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation, :role)
    end
end
