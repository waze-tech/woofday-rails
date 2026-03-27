class DashboardController < ApplicationController
  def show
    @user = Current.user
    @pets = @user.pets.alphabetically
    @upcoming_bookings = @user.bookings.upcoming.includes(:pet, :pro_profile).limit(5)
    @past_bookings = @user.bookings.past.includes(:pet, :pro_profile).limit(5)

    if @user.pro?
      @pro_profile = @user.pro_profile
      @pro_bookings = @pro_profile&.bookings&.upcoming&.includes(:pet)&.limit(10)
      
      # Handle Stripe subscription success redirect
      if params[:subscription] == "success"
        flash.now[:notice] = "🎉 Welcome to Pro! Your subscription is now active."
      end
    end
  end
end
