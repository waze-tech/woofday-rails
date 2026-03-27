class Pros::SetupsController < ApplicationController
  before_action :set_pro_profile
  before_action :redirect_if_complete, only: %i[ show update ]

  def show
    @step = @pro_profile.current_setup_step
  end

  def update
    case @pro_profile.current_setup_step
    when 1
      update_instagram_step
    when 2
      update_profile_step
    when 3
      update_services_step
    end
  end

  def complete
    @pro_profile.complete_setup!
    
    # If user selected Pro plan during signup, redirect to Stripe checkout
    if session[:selected_plan] == "pro"
      session.delete(:selected_plan)
      redirect_to_stripe_checkout
    else
      redirect_to dashboard_path, notice: "Welcome to woof.day! Your profile is now live."
    end
  end

  private

    def set_pro_profile
      @pro_profile = Current.user.pro_profile || Current.user.create_pro_profile!(setup_step: 1)
    end

    def redirect_if_complete
      redirect_to dashboard_path if @pro_profile.setup_complete?
    end

    def update_instagram_step
      @pro_profile.update(instagram: params[:instagram])
      @pro_profile.advance_setup!
      redirect_to pros_setup_path
    end

    def update_profile_step
      if @pro_profile.update(profile_params)
        @pro_profile.advance_setup!
        redirect_to pros_setup_path
      else
        @step = 2
        render :show, status: :unprocessable_entity
      end
    end

    def update_services_step
      # Services are added via Pros::Setups::ServicesController
      @pro_profile.complete_setup!
      
      # If user selected Pro plan during signup, redirect to Stripe checkout
      if session[:selected_plan] == "pro"
        session.delete(:selected_plan)
        redirect_to_stripe_checkout
      else
        redirect_to dashboard_path, notice: "Your profile is live!"
      end
    end
    
    def redirect_to_stripe_checkout
      service = StripeCheckoutService.new(@pro_profile)
      
      checkout_session = service.create_subscription_checkout(
        success_url: dashboard_url(subscription: "success"),
        cancel_url: dashboard_url
      )
      
      redirect_to checkout_session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe checkout error: #{e.message}"
      redirect_to dashboard_path, notice: "Your profile is live! You can upgrade to Pro anytime from your dashboard."
    end

    def profile_params
      params.require(:pro_profile).permit(:business_name, :bio, :location, :phone, :email)
    end
end
