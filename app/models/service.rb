class Service < ApplicationRecord
  belongs_to :pro_profile

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :payment_type, presence: true, inclusion: { in: %w[per_session per_hour per_day] }

  CURRENCIES = [
    { code: "EUR", symbol: "€", name: "Euro" },
    { code: "USD", symbol: "$", name: "US Dollar" },
    { code: "GBP", symbol: "£", name: "British Pound" },
    { code: "AUD", symbol: "A$", name: "Australian Dollar" },
    { code: "CAD", symbol: "C$", name: "Canadian Dollar" }
  ].freeze

  PAYMENT_TYPES = %w[per_session per_hour per_day].freeze

  DURATIONS = [
    "15 minutes", "30 minutes", "45 minutes",
    "1 hour", "1.5 hours", "2 hours", "2.5 hours", "3 hours", "4 hours",
    "Half day", "Full day"
  ].freeze

  def currency_symbol
    CURRENCIES.find { |c| c[:code] == currency }&.dig(:symbol) || "€"
  end

  def formatted_price
    "#{currency_symbol}#{price}"
  end

  def payment_type_label
    case payment_type
    when "per_hour" then "/hour"
    when "per_day" then "/day"
    else "/session"
    end
  end
end
