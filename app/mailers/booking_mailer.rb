class BookingMailer < ApplicationMailer
  default from: "woof.day <noreply@woof.day>"

  # Sent to Pro when customer requests a booking
  def request_received(booking)
    @booking = booking
    @pro = booking.pro_profile
    @customer = booking.customer
    @pet = booking.pet
    @service = booking.service

    mail(
      to: @pro.user.email_address,
      subject: "New booking request from #{@customer.display_name}"
    )
  end

  # Sent to Customer when Pro confirms booking
  def confirmed(booking)
    @booking = booking
    @pro = booking.pro_profile
    @customer = booking.customer

    mail(
      to: @customer.email_address,
      subject: "Your booking with #{@pro.business_name} is confirmed!"
    )
  end

  # Sent to Customer when Pro declines booking
  def declined(booking)
    @booking = booking
    @pro = booking.pro_profile
    @customer = booking.customer

    mail(
      to: @customer.email_address,
      subject: "Booking update from #{@pro.business_name}"
    )
  end

  # Sent to both parties when booking is cancelled
  def cancelled(booking, cancelled_by:)
    @booking = booking
    @pro = booking.pro_profile
    @customer = booking.customer
    @cancelled_by = cancelled_by

    # Send to the other party
    recipient = cancelled_by == "customer" ? @pro.user.email_address : @customer.email_address

    mail(
      to: recipient,
      subject: "Booking cancelled"
    )
  end

  # Sent to Customer when booking is marked complete
  def completed(booking)
    @booking = booking
    @pro = booking.pro_profile
    @customer = booking.customer

    mail(
      to: @customer.email_address,
      subject: "Your appointment with #{@pro.business_name} is complete"
    )
  end

  # Sent to Customer to request a review
  def review_request(booking)
    @booking = booking
    @pro = booking.pro_profile
    @customer = booking.customer

    mail(
      to: @customer.email_address,
      subject: "How was your visit to #{@pro.business_name}?"
    )
  end
end
