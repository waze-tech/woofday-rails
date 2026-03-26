# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_26_195314) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.datetime "end_time"
    t.text "notes"
    t.bigint "pet_id", null: false
    t.bigint "pro_profile_id", null: false
    t.bigint "service_id"
    t.datetime "start_time"
    t.string "status"
    t.decimal "total_price"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_bookings_on_customer_id"
    t.index ["pet_id"], name: "index_bookings_on_pet_id"
    t.index ["pro_profile_id"], name: "index_bookings_on_pro_profile_id"
    t.index ["service_id"], name: "index_bookings_on_service_id"
  end

  create_table "pets", force: :cascade do |t|
    t.integer "age"
    t.string "breed"
    t.datetime "created_at", null: false
    t.string "name"
    t.text "notes"
    t.string "photo_url"
    t.string "size"
    t.string "species"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "pro_profiles", force: :cascade do |t|
    t.text "bio"
    t.string "business_name"
    t.datetime "created_at", null: false
    t.string "email"
    t.decimal "hourly_rate"
    t.string "instagram"
    t.boolean "is_verified", default: false
    t.decimal "latitude", precision: 10, scale: 8
    t.string "location"
    t.decimal "longitude", precision: 11, scale: 8
    t.string "phone"
    t.integer "service_radius_km", default: 10
    t.text "services"
    t.boolean "setup_completed"
    t.integer "setup_step"
    t.string "slug"
    t.datetime "subscription_expires_at"
    t.string "subscription_tier", default: "free"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified"
    t.index ["slug"], name: "index_pro_profiles_on_slug", unique: true
    t.index ["user_id"], name: "index_pro_profiles_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "publish_after"
    t.datetime "published_at"
    t.integer "rating"
    t.bigint "reviewer_id", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency"
    t.text "description"
    t.string "duration"
    t.string "name"
    t.string "payment_type"
    t.decimal "price"
    t.bigint "pro_profile_id", null: false
    t.datetime "updated_at", null: false
    t.index ["pro_profile_id"], name: "index_services_on_pro_profile_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "location"
    t.string "name"
    t.string "password_digest", null: false
    t.string "phone"
    t.string "provider"
    t.string "role"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "bookings", "pets"
  add_foreign_key "bookings", "pro_profiles"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "users", column: "customer_id"
  add_foreign_key "pets", "users"
  add_foreign_key "pro_profiles", "users"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "services", "pro_profiles"
  add_foreign_key "sessions", "users"
end
