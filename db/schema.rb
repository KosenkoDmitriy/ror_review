# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170822122235) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.text "street"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "zipcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_responses", force: :cascade do |t|
    t.text "client_reply"
    t.bigint "user_id"
    t.bigint "response_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "google_review_id"
    t.index ["google_review_id"], name: "index_client_responses_on_google_review_id"
    t.index ["response_id"], name: "index_client_responses_on_response_id"
    t.index ["user_id"], name: "index_client_responses_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "send_request_email"
    t.string "send_request_mobile_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "address_id"
    t.string "website"
    t.text "originator"
    t.string "google_client_id"
    t.string "google_secret_key"
    t.string "google_refresh_token"
    t.string "google_account_name"
  end

  create_table "google_reviews", force: :cascade do |t|
    t.string "google_review_id"
    t.string "reviewer_name"
    t.string "star_rating"
    t.text "review_comment"
    t.datetime "google_review_create_time"
    t.datetime "google_review_update_time"
    t.bigint "location_id"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_google_reviews_on_client_id"
    t.index ["location_id"], name: "index_google_reviews_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "email_template_id"
    t.integer "phone_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "address_id"
    t.string "google_place_id"
    t.string "location_phone_no"
    t.bigint "clients_id"
    t.string "google_location_id"
    t.index ["clients_id"], name: "index_locations_on_clients_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.boolean "email_notification_type"
    t.boolean "push_notification_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "users_id"
    t.bigint "notification_types_id"
    t.index ["notification_types_id"], name: "index_notification_settings_on_notification_types_id"
    t.index ["users_id"], name: "index_notification_settings_on_users_id"
  end

  create_table "notification_types", force: :cascade do |t|
    t.string "notification_name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.integer "location_id"
    t.datetime "send_at"
    t.boolean "clicked"
    t.datetime "clicked_at"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "review_user_id"
    t.index ["review_user_id"], name: "index_requests_on_review_user_id"
  end

  create_table "response_notes", force: :cascade do |t|
    t.text "note_text"
    t.bigint "user_id"
    t.bigint "response_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "google_review_id"
    t.index ["google_review_id"], name: "index_response_notes_on_google_review_id"
    t.index ["response_id"], name: "index_response_notes_on_response_id"
    t.index ["user_id"], name: "index_response_notes_on_user_id"
  end

  create_table "responses", force: :cascade do |t|
    t.boolean "positive"
    t.string "url"
    t.text "feedback"
    t.boolean "google_review"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "request_id"
    t.index ["request_id"], name: "index_responses_on_request_id"
  end

  create_table "review_users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone_no"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "originator"
    t.string "country_code"
    t.index ["client_id"], name: "index_review_users_on_client_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.date "next_billing_date"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_subscriptions_on_client_id"
  end

  create_table "templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_id"
    t.string "template_text"
    t.string "email_subject"
    t.boolean "is_email"
    t.index ["client_id"], name: "index_templates_on_client_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "first_name"
    t.string "last_name"
    t.integer "client_id"
    t.boolean "active", default: true, null: false
    t.string "primary_mobile_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "client_responses", "google_reviews"
  add_foreign_key "client_responses", "responses"
  add_foreign_key "client_responses", "users"
  add_foreign_key "google_reviews", "clients"
  add_foreign_key "google_reviews", "locations"
  add_foreign_key "locations", "clients", column: "clients_id"
  add_foreign_key "notification_settings", "notification_types", column: "notification_types_id"
  add_foreign_key "notification_settings", "users", column: "users_id"
  add_foreign_key "requests", "review_users"
  add_foreign_key "response_notes", "google_reviews"
  add_foreign_key "response_notes", "responses"
  add_foreign_key "response_notes", "users"
  add_foreign_key "responses", "requests"
  add_foreign_key "review_users", "clients"
  add_foreign_key "subscriptions", "clients"
  add_foreign_key "templates", "clients"
end
