# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :require_authentication

    def create
      payload = request.body.read
      signature = request.headers["Stripe-Signature"]

      result = StripeWebhookService.new(payload, signature).process!

      if result[:success]
        render json: { received: true, event: result[:event_type] }, status: :ok
      else
        render json: { error: result[:error] }, status: :bad_request
      end
    end
  end
end
