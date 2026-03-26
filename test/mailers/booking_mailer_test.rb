require "test_helper"

class BookingMailerTest < ActionMailer::TestCase
  test "request_received" do
    mail = BookingMailer.request_received
    assert_equal "Request received", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "confirmed" do
    mail = BookingMailer.confirmed
    assert_equal "Confirmed", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "declined" do
    mail = BookingMailer.declined
    assert_equal "Declined", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "cancelled" do
    mail = BookingMailer.cancelled
    assert_equal "Cancelled", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "completed" do
    mail = BookingMailer.completed
    assert_equal "Completed", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "review_request" do
    mail = BookingMailer.review_request
    assert_equal "Review request", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
