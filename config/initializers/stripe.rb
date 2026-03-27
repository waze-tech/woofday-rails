# frozen_string_literal: true

Rails.application.config.stripe = {
  secret_key: ENV["STRIPE_SECRET_KEY"],
  publishable_key: ENV["STRIPE_PUBLISHABLE_KEY"],
  webhook_secret: ENV["STRIPE_WEBHOOK_SECRET"],
  pro_monthly_price_id: ENV["STRIPE_PRO_MONTHLY_PRICE_ID"]
}

Stripe.api_key = Rails.application.config.stripe[:secret_key]
