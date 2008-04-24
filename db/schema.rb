# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 53) do

  create_table "acts_as_xapian_jobs", :force => true do |t|
    t.string  "model",    :null => false
    t.integer "model_id", :null => false
    t.string  "action",   :null => false
  end

  add_index "acts_as_xapian_jobs", ["model", "model_id"], :name => "index_acts_as_xapian_jobs_on_model_and_model_id", :unique => true

  create_table "incoming_messages", :force => true do |t|
    t.integer  "info_request_id", :null => false
    t.text     "raw_data",        :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "info_request_events", :force => true do |t|
    t.integer  "info_request_id",     :null => false
    t.text     "event_type",          :null => false
    t.text     "params_yaml",         :null => false
    t.datetime "created_at",          :null => false
    t.string   "described_state"
    t.string   "calculated_state"
    t.datetime "last_described_at"
    t.integer  "incoming_message_id"
    t.integer  "outgoing_message_id"
  end

  create_table "info_requests", :force => true do |t|
    t.text     "title",                                      :null => false
    t.integer  "user_id",                                    :null => false
    t.integer  "public_body_id",                             :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "described_state",                            :null => false
    t.boolean  "awaiting_description", :default => false,    :null => false
    t.string   "prominence",           :default => "normal", :null => false
    t.text     "url_title",                                  :null => false
  end

  add_index "info_requests", ["created_at"], :name => "index_info_requests_on_created_at"
  add_index "info_requests", ["title"], :name => "index_info_requests_on_title"
  add_index "info_requests", ["url_title"], :name => "index_info_requests_on_url_title", :unique => true

  create_table "outgoing_messages", :force => true do |t|
    t.integer  "info_request_id",              :null => false
    t.text     "body",                         :null => false
    t.string   "status",                       :null => false
    t.string   "message_type",                 :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.datetime "last_sent_at"
    t.integer  "incoming_message_followup_id"
  end

  create_table "post_redirects", :force => true do |t|
    t.text     "token",                                    :null => false
    t.text     "uri",                                      :null => false
    t.text     "post_params_yaml"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.text     "email_token",                              :null => false
    t.text     "reason_params_yaml"
    t.integer  "user_id"
    t.text     "circumstance",       :default => "normal", :null => false
  end

  add_index "post_redirects", ["email_token"], :name => "index_post_redirects_on_email_token"
  add_index "post_redirects", ["token"], :name => "index_post_redirects_on_token"
  add_index "post_redirects", ["updated_at"], :name => "index_post_redirects_on_updated_at"

  create_table "public_bodies", :force => true do |t|
    t.text     "name",              :null => false
    t.text     "short_name",        :null => false
    t.text     "request_email",     :null => false
    t.integer  "version",           :null => false
    t.string   "last_edit_editor",  :null => false
    t.text     "last_edit_comment", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.text     "url_name",          :null => false
  end

  add_index "public_bodies", ["url_name"], :name => "index_public_bodies_on_url_name", :unique => true

  create_table "public_body_tags", :force => true do |t|
    t.integer  "public_body_id", :null => false
    t.text     "name",           :null => false
    t.datetime "created_at",     :null => false
  end

  add_index "public_body_tags", ["public_body_id", "name"], :name => "index_public_body_tags_on_public_body_id_and_name", :unique => true

  create_table "public_body_versions", :force => true do |t|
    t.integer  "public_body_id"
    t.integer  "version"
    t.text     "name"
    t.text     "short_name"
    t.text     "request_email"
    t.datetime "updated_at"
    t.string   "last_edit_editor"
    t.string   "last_edit_comment"
    t.text     "url_name"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "track_things", :force => true do |t|
    t.integer  "tracking_user_id", :null => false
    t.string   "track_query",      :null => false
    t.integer  "info_request_id"
    t.integer  "tracked_user_id"
    t.integer  "public_body_id"
    t.string   "track_medium",     :null => false
    t.string   "track_type",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "track_things", ["tracking_user_id", "track_query"], :name => "index_track_things_on_tracking_user_id_and_track_query", :unique => true

  create_table "track_things_sent_emails", :force => true do |t|
    t.integer  "track_thing_id",        :null => false
    t.integer  "info_request_event_id"
    t.integer  "user_id"
    t.integer  "public_body_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_info_request_sent_alerts", :force => true do |t|
    t.integer "user_id",               :null => false
    t.integer "info_request_id",       :null => false
    t.string  "alert_type",            :null => false
    t.integer "info_request_event_id"
  end

  add_index "user_info_request_sent_alerts", ["user_id", "info_request_id", "alert_type"], :name => "user_info_request_sent_alerts_unique_index", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                                     :null => false
    t.string   "name",                                                      :null => false
    t.string   "hashed_password",                                           :null => false
    t.string   "salt",                                                      :null => false
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.boolean  "email_confirmed",        :default => false,                 :null => false
    t.text     "url_name",                                                  :null => false
    t.datetime "last_daily_track_email", :default => '2000-01-01 00:00:00'
  end

  add_index "users", ["url_name"], :name => "index_users_on_url_name", :unique => true

end
