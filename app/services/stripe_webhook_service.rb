# frozen_string_literal: true

class StripeWebhookService
  def initialize(payload, signature)
    @payload = payload
    @signature = signature
  end

  def process!
    event = construct_event
    return { success: false, error: "Invalid signature" } unless event

    handle_event(event)
    { success: true, event_type: event.type }
  rescue Stripe::SignatureVerificationError => e
    Rails.logger.error "Stripe webhook signature error: #{e.message}"
    { success: false, error: "Invalid signature" }
  rescue StandardError => e
    Rails.logger.error "Stripe webhook error: #{e.message}"
    { success: false, error: e.message }
  end

  private

  def construct_event
    webhook_secret = Rails.application.config.stripe[:webhook_secret]
    
    # In development/test, skip signature verification if no secret
    if webhook_secret.blank?
      Rails.logger.warn "Stripe webhook secret not configured, parsing without verification"
      return Stripe::Event.construct_from(JSON.parse(@payload))
    end

    Stripe::Webhook.construct_event(@payload, @signature, webhook_secret)
  end

  def handle_event(event)
    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    when "customer.subscription.created", "customer.subscription.updated"
      handle_subscription_updated(event.data.object)
    when "customer.subscription.deleted"
      handle_subscription_deleted(event.data.object)
    when "invoice.payment_failed"
      handle_payment_failed(event.data.object)
    else
      Rails.logger.info "Unhandled Stripe event: #{event.type}"
    end
  end

  def handle_checkout_completed(session)
    return unless session.metadata&.type == "pro_subscription"
    
    pro_profile_id = session.metadata&.pro_profile_id
    return unless pro_profile_id

    pro_profile = ProProfile.find_by(id: pro_profile_id)
    return unless pro_profile

    if session.subscription
      subscription = Stripe::Subscription.retrieve(session.subscription)
      update_subscription_status(pro_profile, subscription)
    end

    Rails.logger.info "Pro subscription checkout completed for profile #{pro_profile_id}"
  end

  def handle_subscription_updated(subscription)
    pro_profile = find_profile_by_subscription(subscription)
    return unless pro_profile

    update_subscription_status(pro_profile, subscription)
    Rails.logger.info "Subscription updated for profile #{pro_profile.id}: #{subscription.status}"
  end

  def handle_subscription_deleted(subscription)
    pro_profile = find_profile_by_subscription(subscription)
    return unless pro_profile

    pro_profile.update!(
      subscription_tier: "free",
      subscription_expires_at: nil,
      stripe_subscription_id: nil
    )

    Rails.logger.info "Subscription cancelled for profile #{pro_profile.id}"
  end

  def handle_payment_failed(invoice)
    return unless invoice.subscription

    subscription = Stripe::Subscription.retrieve(invoice.subscription)
    pro_profile = find_profile_by_subscription(subscription)
    return unless pro_profile

    # Could send email notification here
    Rails.logger.warn "Payment failed for profile #{pro_profile.id}"
  end

  def find_profile_by_subscription(subscription)
    # First try by subscription ID
    profile = ProProfile.find_by(stripe_subscription_id: subscription.id)
    return profile if profile

    # Fall back to customer ID
    profile = ProProfile.find_by(stripe_customer_id: subscription.customer)
    return profile if profile

    # Try metadata
    pro_profile_id = subscription.metadata&.pro_profile_id
    ProProfile.find_by(id: pro_profile_id) if pro_profile_id
  end

  def update_subscription_status(pro_profile, subscription)
    tier = subscription.status == "active" ? "pro" : "free"
    expires_at = subscription.status == "active" ? Time.at(subscription.current_period_end) : nil

    pro_profile.update!(
      subscription_tier: tier,
      subscription_expires_at: expires_at,
      stripe_subscription_id: subscription.id
    )
  end
end
