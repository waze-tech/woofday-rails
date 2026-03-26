# Preview all emails at http://localhost:3000/rails/mailers/booking_mailer
class BookingMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/request_received
  def request_received
    BookingMailer.request_received
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/confirmed
  def confirmed
    BookingMailer.confirmed
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/declined
  def declined
    BookingMailer.declined
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/cancelled
  def cancelled
    BookingMailer.cancelled
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/completed
  def completed
    BookingMailer.completed
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/review_request
  def review_request
    BookingMailer.review_request
  end
end
