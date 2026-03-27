# frozen_string_literal: true

class StripeCheckoutService
  PRO_MONTHLY_PRICE = 1900 # €19.00 in cents

  def initialize(pro_profile)
    @pro_profile = pro_profile
    @user = pro_profile.user
  end

  def create_subscription_checkout(success_url:, cancel_url:)
    customer = find_or_create_customer
    
    session = Stripe::Checkout::Session.create(
      customer: customer.id,
      payment_method_types: ["card"],
      line_items: [{
        price_data: {
          currency: "eur",
          product_data: {
            name: "Woof.Day Pro Plan",
            description: "Monthly subscription for pet care professionals"
          },
          unit_amount: PRO_MONTHLY_PRICE,
          recurring: { interval: "month" }
        },
        quantity: 1
      }],
      mode: "subscription",
      success_url: success_url,
      cancel_url: cancel_url,
      metadata: {
        pro_profile_id: @pro_profile.id,
        type: "pro_subscription"
      }
    )
    
    session
  end

  def create_customer_portal_session(return_url:)
    return nil unless @pro_profile.stripe_customer_id
    
    Stripe::BillingPortal::Session.create(
      customer: @pro_profile.stripe_customer_id,
      return_url: return_url
    )
  end

  private

  def find_or_create_customer
    if @pro_profile.stripe_customer_id
      begin
        return Stripe::Customer.retrieve(@pro_profile.stripe_customer_id)
      rescue Stripe::InvalidRequestError
        # Customer was deleted, create new one
      end
    end

    customer = Stripe::Customer.create(
      email: @user.email_address,
      metadata: {
        pro_profile_id: @pro_profile.id,
        user_id: @user.id
      }
    )

    @pro_profile.update!(stripe_customer_id: customer.id)
    customer
  end
end
