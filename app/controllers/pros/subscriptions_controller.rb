# frozen_string_literal: true

module Pros
  class SubscriptionsController < ApplicationController
    before_action :set_pro_profile

    def show
      if params[:inline]
        render partial: "pros/subscriptions/inline", layout: false
      end
    end

    def create
      service = StripeCheckoutService.new(@pro_profile)
      
      session = service.create_subscription_checkout(
        success_url: pros_subscription_url(success: true),
        cancel_url: pricing_url
      )

      redirect_to session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      redirect_to pricing_path, alert: "Unable to start checkout: #{e.message}"
    end

    def portal
      service = StripeCheckoutService.new(@pro_profile)
      
      session = service.create_customer_portal_session(
        return_url: pros_subscription_url
      )

      if session
        redirect_to session.url, allow_other_host: true
      else
        redirect_to pros_subscription_path, alert: "No active subscription to manage"
      end
    rescue Stripe::StripeError => e
      redirect_to pros_subscription_path, alert: "Unable to access billing portal: #{e.message}"
    end

    private

    def set_pro_profile
      @pro_profile = Current.user.pro_profile
      
      unless @pro_profile
        redirect_to new_pro_profile_path, alert: "Please set up your pro profile first"
      end
    end
  end
end
