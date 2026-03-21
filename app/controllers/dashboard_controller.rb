class DashboardController < ApplicationController
  def show
    @user = Current.user
    @pets = @user.pets.alphabetically
    @upcoming_bookings = @user.bookings.upcoming.includes(:pet, :pro_profile).limit(5)
    @past_bookings = @user.bookings.past.includes(:pet, :pro_profile).limit(5)

    if @user.pro?
      @pro_profile = @user.pro_profile
      @pro_bookings = @pro_profile&.bookings&.upcoming&.includes(:pet)&.limit(10)
    end
  end
end
