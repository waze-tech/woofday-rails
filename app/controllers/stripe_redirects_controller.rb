# frozen_string_literal: true

class StripeRedirectsController < ApplicationController
  def show
    @checkout_url = session.delete(:stripe_checkout_url)
    
    unless @checkout_url
      redirect_to root_path, alert: "No checkout session found"
    end
  end
end
