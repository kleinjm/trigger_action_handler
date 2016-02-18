# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160217235914) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.integer  "trigger_id"
    t.integer  "crud_action_id"
    t.string   "klass"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agent_contacts", force: :cascade do |t|
    t.integer  "property_id"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lead_id"
    t.integer  "agent_id"
  end

  create_table "agents", force: :cascade do |t|
    t.string   "first_name",     limit: 50
    t.string   "last_name",      limit: 50
    t.string   "address1"
    t.string   "address2",       limit: 50
    t.string   "city",           limit: 100
    t.string   "state",          limit: 20
    t.string   "zipcode",        limit: 10
    t.string   "office_phone",   limit: 30
    t.string   "cell_phone",     limit: 30
    t.string   "fax",            limit: 30
    t.string   "title"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_login"
    t.string   "license_number"
  end

  create_table "conditions", force: :cascade do |t|
    t.integer  "trigger_id"
    t.string   "operator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crud_actions", force: :cascade do |t|
    t.string "name"
  end

  create_table "deal_stages", force: :cascade do |t|
    t.string  "name"
    t.boolean "open",   default: true
    t.boolean "closed", default: false
    t.boolean "dead",   default: false
  end

  create_table "deals", force: :cascade do |t|
    t.integer  "property_id"
    t.integer  "lead_id"
    t.integer  "agent_id"
    t.string   "name"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
    t.date     "offer_date"
    t.date     "ps_date"
    t.date     "proj_closing_date"
    t.date     "actual_closing_date"
    t.integer  "current_stage_id"
    t.date     "stage_changed_on"
    t.integer  "price"
    t.integer  "deposit"
    t.integer  "total_commission"
    t.decimal  "house_commission",    precision: 10, scale: 2
    t.decimal  "agent_commission",    precision: 10, scale: 2
    t.decimal  "cobroke_commission",  precision: 10, scale: 2
  end

  create_table "events", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "assignee_id"
    t.integer  "lead_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "name"
    t.text     "description"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "deal_id"
    t.integer  "property_id"
    t.boolean  "cancelled",   default: false, null: false
  end

  create_table "field_value_pairs", force: :cascade do |t|
    t.integer "owner_id"
    t.string  "owner_type"
    t.string  "field"
    t.string  "value"
  end

  create_table "lead_priorities", force: :cascade do |t|
    t.string "name"
  end

  create_table "lead_statuses", force: :cascade do |t|
    t.string "name"
  end

  create_table "lead_types", force: :cascade do |t|
    t.string "name"
  end

  create_table "leads", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "lead_type_id"
    t.integer  "lead_status_id"
    t.integer  "lead_priority_id"
    t.text     "comments"
    t.datetime "next_followup"
    t.datetime "last_active"
    t.string   "first_name",          limit: 50
    t.string   "last_name",           limit: 50
    t.string   "email"
    t.string   "address"
    t.string   "city",                limit: 20
    t.string   "state",               limit: 3,  default: ""
    t.string   "zip_code",            limit: 10
    t.string   "country_name"
    t.string   "phone1",              limit: 21
    t.string   "phone2",              limit: 21
    t.string   "phone3",              limit: 21
    t.integer  "phone_type_1"
    t.integer  "phone_type_2"
    t.integer  "phone_type_3"
    t.string   "phone1_ext"
    t.string   "phone2_ext"
    t.string   "phone3_ext"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "bounced",                        default: false, null: false
    t.boolean  "mailing_list_signup",            default: false, null: false
    t.integer  "total_logic_score",              default: 1,     null: false
    t.integer  "recent_logic_score",             default: 0,     null: false
    t.datetime "unsubscribed_all_at"
  end

  create_table "marketing_list_leads", force: :cascade do |t|
    t.integer  "marketing_list_id"
    t.integer  "lead_id"
    t.datetime "unsubscribed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "removed_at"
  end

  create_table "marketing_lists", force: :cascade do |t|
    t.integer  "agent_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phone_types", force: :cascade do |t|
    t.string "name"
  end

  create_table "property_views", force: :cascade do |t|
    t.integer  "lead_id"
    t.integer  "property_id"
    t.datetime "created_at"
  end

  create_table "showings", force: :cascade do |t|
    t.integer  "property_id"
    t.text     "comments"
    t.datetime "showing_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lead_id"
    t.integer  "agent_id"
  end

  create_table "task_priorities", force: :cascade do |t|
    t.string "name"
  end

  create_table "task_statuses", force: :cascade do |t|
    t.string "name"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "assignee_id"
    t.integer  "completer_id"
    t.integer  "lead_id"
    t.datetime "due_date"
    t.datetime "completed_at"
    t.integer  "task_status_id"
    t.integer  "task_priority_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "deal_id"
    t.integer  "property_id"
  end

  create_table "triggers", force: :cascade do |t|
    t.integer  "crud_action_id"
    t.string   "klass"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
