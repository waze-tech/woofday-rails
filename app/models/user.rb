class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Pets owned by this user
  has_many :pets, dependent: :destroy

  # Pro profile (if user is a pro)
  has_one :pro_profile, dependent: :destroy

  # Reviews written by this user
  has_many :reviews, foreign_key: :reviewer_id, dependent: :destroy

  # Bookings through pets
  has_many :bookings, through: :pets

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Roles
  enum :role, { pet_owner: "pet_owner", pro: "pro", admin: "admin" }, default: :pet_owner

  def pro?
    role == "pro" || pro_profile.present?
  end

  def display_name
    email_address.split("@").first.titleize
  end

  # OAuth support
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email_address = auth.info.email
      user.password = SecureRandom.hex(16)
      user.provider = auth.provider
      user.uid = auth.uid
    end
  end
end
