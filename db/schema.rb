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

ActiveRecord::Schema.define(version: 20161212044704) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ad_banner_banners", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "mime_type"
    t.integer  "size"
    t.integer  "image_is"
    t.integer  "image_width"
    t.integer  "image_height"
    t.integer  "content_id"
    t.integer  "group_id"
    t.string   "state"
    t.string   "advertiser_name"
    t.string   "advertiser_phone"
    t.string   "advertiser_email"
    t.string   "advertiser_contact"
    t.datetime "published_at"
    t.datetime "closed_at"
    t.string   "url"
    t.integer  "sort_no"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "target"
    t.integer  "site_id"
    t.integer  "thumb_width"
    t.integer  "thumb_height"
    t.integer  "thumb_size"
    t.index ["token"], name: "index_ad_banner_banners_on_token", unique: true, using: :btree
  end

  create_table "ad_banner_clicks", force: :cascade do |t|
    t.integer  "banner_id"
    t.string   "referer"
    t.string   "remote_addr"
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ad_banner_groups", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "name"
    t.string   "title"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_approval_flows", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "title"
    t.integer  "group_id"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_approval_request_histories", force: :cascade do |t|
    t.integer  "request_id"
    t.integer  "user_id"
    t.string   "reason"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["request_id"], name: "index_approval_approval_request_histories_on_request_id", using: :btree
    t.index ["user_id"], name: "index_approval_approval_request_histories_on_user_id", using: :btree
  end

  create_table "approval_approval_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "approval_flow_id"
    t.integer  "approvable_id"
    t.string   "approvable_type"
    t.integer  "current_index"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "select_assignments"
  end

  create_table "approval_approvals", force: :cascade do |t|
    t.integer  "approval_flow_id"
    t.integer  "index"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "approval_type"
  end

  create_table "approval_assignments", force: :cascade do |t|
    t.integer  "assignable_id"
    t.string   "assignable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "approved_at"
    t.integer  "or_group_id"
    t.integer  "selected_index"
    t.index ["assignable_type", "assignable_id"], name: "index_approval_assignments_on_assignable_type_and_assignable_id", using: :btree
    t.index ["selected_index"], name: "index_approval_assignments_on_selected_index", using: :btree
    t.index ["user_id"], name: "index_approval_assignments_on_user_id", using: :btree
  end

  create_table "biz_calendar_bussiness_holidays", force: :cascade do |t|
    t.integer  "place_id"
    t.string   "state"
    t.integer  "type_id"
    t.date     "holiday_start_date"
    t.date     "holiday_end_date"
    t.string   "repeat_type"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "end_type"
    t.integer  "end_times"
    t.integer  "repeat_interval"
    t.text     "repeat_week"
    t.text     "repeat_criterion"
  end

  create_table "biz_calendar_bussiness_hours", force: :cascade do |t|
    t.integer  "place_id"
    t.string   "state"
    t.date     "fixed_start_date"
    t.date     "fixed_end_date"
    t.string   "repeat_type"
    t.date     "start_date"
    t.date     "end_date"
    t.time     "business_hours_start_time"
    t.time     "business_hours_end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "end_type"
    t.integer  "end_times"
    t.integer  "repeat_interval"
    t.text     "repeat_week"
    t.text     "repeat_criterion"
  end

  create_table "biz_calendar_exception_holidays", force: :cascade do |t|
    t.integer  "place_id"
    t.string   "state"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biz_calendar_holiday_types", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["content_id"], name: "index_biz_calendar_holiday_types_on_content_id", using: :btree
  end

  create_table "biz_calendar_places", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "state"
    t.string   "url"
    t.string   "title"
    t.string   "summary"
    t.string   "description"
    t.string   "business_hours_state"
    t.string   "business_hours_title"
    t.string   "business_holiday_state"
    t.string   "business_holiday_title"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["content_id"], name: "index_biz_calendar_places_on_content_id", using: :btree
  end

  create_table "cms_brackets", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "concept_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["concept_id"], name: "index_cms_brackets_on_concept_id", using: :btree
    t.index ["name"], name: "index_cms_brackets_on_name", using: :btree
    t.index ["owner_type", "owner_id"], name: "index_cms_brackets_on_owner_type_and_owner_id", using: :btree
    t.index ["site_id"], name: "index_cms_brackets_on_site_id", using: :btree
  end

  create_table "cms_concepts", force: :cascade do |t|
    t.integer  "parent_id"
    t.integer  "site_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",   null: false
    t.integer  "sort_no"
    t.string   "name"
    t.index ["parent_id", "state", "sort_no"], name: "index_cms_concepts_on_parent_id_and_state_and_sort_no", using: :btree
  end

  create_table "cms_content_settings", force: :cascade do |t|
    t.integer  "content_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "value"
    t.integer  "sort_no"
    t.text     "extra_value"
    t.index ["content_id"], name: "index_cms_content_settings_on_content_id", using: :btree
  end

  create_table "cms_contents", force: :cascade do |t|
    t.integer  "site_id",        null: false
    t.integer  "concept_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model"
    t.string   "name"
    t.text     "xml_properties"
    t.string   "note"
    t.string   "code"
    t.integer  "sort_no"
  end

  create_table "cms_data_file_nodes", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "concept_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "title"
    t.index ["concept_id", "name"], name: "index_cms_data_file_nodes_on_concept_id_and_name", using: :btree
  end

  create_table "cms_data_files", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "concept_id"
    t.integer  "node_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "name"
    t.text     "title"
    t.text     "mime_type"
    t.integer  "size"
    t.integer  "image_is"
    t.integer  "image_width"
    t.integer  "image_height"
    t.integer  "thumb_width"
    t.integer  "thumb_height"
    t.integer  "thumb_size"
    t.text     "extracted_text"
    t.index ["concept_id", "node_id", "name"], name: "index_cms_data_files_on_concept_id_and_node_id_and_name", using: :btree
  end

  create_table "cms_data_texts", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "concept_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "name"
    t.text     "title"
    t.text     "body"
  end

  create_table "cms_feed_entries", force: :cascade do |t|
    t.integer  "feed_id"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "entry_id"
    t.datetime "entry_updated"
    t.date     "event_date"
    t.text     "title"
    t.text     "summary"
    t.text     "link_alternate"
    t.text     "link_enclosure"
    t.text     "categories"
    t.text     "author_name"
    t.string   "author_email"
    t.text     "author_uri"
    t.index ["feed_id", "content_id", "entry_updated"], name: "idx_cms_feed_entries_on_f_id_and_c_id_and_e_updated", using: :btree
  end

  create_table "cms_feeds", force: :cascade do |t|
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",           null: false
    t.text     "uri"
    t.text     "title"
    t.string   "feed_id"
    t.string   "feed_type"
    t.datetime "feed_updated"
    t.text     "feed_title"
    t.text     "link_alternate"
    t.integer  "entry_count"
  end

  create_table "cms_inquiries", force: :cascade do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.text     "charge"
    t.text     "tel"
    t.text     "fax"
    t.text     "email"
    t.integer  "inquirable_id"
    t.string   "inquirable_type"
    t.index ["inquirable_type", "inquirable_id"], name: "index_cms_inquiries_on_inquirable_type_and_inquirable_id", using: :btree
  end

  create_table "cms_kana_dictionaries", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "body"
    t.text     "mecab_csv"
    t.integer  "site_id"
  end

  create_table "cms_layouts", force: :cascade do |t|
    t.integer  "concept_id"
    t.integer  "template_id"
    t.integer  "site_id",                null: false
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.string   "name"
    t.text     "title"
    t.text     "head"
    t.text     "body"
    t.text     "stylesheet"
    t.text     "mobile_head"
    t.text     "mobile_body"
    t.text     "mobile_stylesheet"
    t.text     "smart_phone_head"
    t.text     "smart_phone_body"
    t.text     "smart_phone_stylesheet"
  end

  create_table "cms_link_check_logs", force: :cascade do |t|
    t.integer  "link_check_id"
    t.integer  "link_checkable_id"
    t.string   "link_checkable_type"
    t.boolean  "checked"
    t.string   "title"
    t.string   "body"
    t.string   "url"
    t.integer  "status"
    t.string   "reason"
    t.boolean  "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_link_checks", force: :cascade do |t|
    t.boolean  "in_progress"
    t.boolean  "checked"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_links", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "linkable_type"
    t.integer  "linkable_id"
    t.string   "body"
    t.string   "url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "cms_map_markers", force: :cascade do |t|
    t.integer  "map_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.string   "name"
    t.string   "lat"
    t.string   "lng"
    t.index ["map_id"], name: "index_cms_map_markers_on_map_id", using: :btree
  end

  create_table "cms_maps", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "title"
    t.text     "map_lat"
    t.text     "map_lng"
    t.text     "map_zoom"
    t.text     "point1_name"
    t.text     "point1_lat"
    t.text     "point1_lng"
    t.text     "point2_name"
    t.text     "point2_lat"
    t.text     "point2_lng"
    t.text     "point3_name"
    t.text     "point3_lat"
    t.text     "point3_lng"
    t.text     "point4_name"
    t.text     "point4_lat"
    t.text     "point4_lng"
    t.text     "point5_name"
    t.text     "point5_lat"
    t.text     "point5_lng"
    t.integer  "map_attachable_id"
    t.string   "map_attachable_type"
    t.index ["map_attachable_type", "map_attachable_id"], name: "index_cms_maps_on_map_attachable_type_and_map_attachable_id", using: :btree
  end

  create_table "cms_nodes", force: :cascade do |t|
    t.integer  "concept_id"
    t.integer  "site_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "parent_id"
    t.integer  "route_id"
    t.integer  "content_id"
    t.string   "model"
    t.integer  "directory"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
    t.text     "body"
    t.text     "mobile_title"
    t.text     "mobile_body"
    t.string   "sitemap_state"
    t.integer  "sitemap_sort_no"
    t.index ["concept_id"], name: "index_cms_nodes_on_concept_id", using: :btree
    t.index ["content_id"], name: "index_cms_nodes_on_content_id", using: :btree
    t.index ["layout_id"], name: "index_cms_nodes_on_layout_id", using: :btree
    t.index ["parent_id", "name"], name: "index_cms_nodes_on_parent_id_and_name", using: :btree
    t.index ["parent_id"], name: "index_cms_nodes_on_parent_id", using: :btree
    t.index ["route_id"], name: "index_cms_nodes_on_route_id", using: :btree
    t.index ["site_id"], name: "index_cms_nodes_on_site_id", using: :btree
    t.index ["state"], name: "index_cms_nodes_on_state", using: :btree
  end

  create_table "cms_o_auth_users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname"
    t.string   "url"
  end

  create_table "cms_piece_link_items", force: :cascade do |t|
    t.integer  "piece_id",   null: false
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "body"
    t.string   "uri"
    t.integer  "sort_no"
    t.string   "target"
    t.index ["piece_id"], name: "index_cms_piece_link_items_on_piece_id", using: :btree
  end

  create_table "cms_piece_settings", force: :cascade do |t|
    t.integer  "piece_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "value"
    t.integer  "sort_no"
    t.text     "extra_value"
    t.index ["piece_id"], name: "index_cms_piece_settings_on_piece_id", using: :btree
  end

  create_table "cms_pieces", force: :cascade do |t|
    t.integer  "concept_id"
    t.integer  "site_id",        null: false
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "content_id"
    t.string   "model"
    t.string   "name"
    t.text     "title"
    t.string   "view_title"
    t.text     "head"
    t.text     "body"
    t.text     "xml_properties"
    t.text     "etcetera"
    t.index ["concept_id", "name", "state"], name: "index_cms_pieces_on_concept_id_and_name_and_state", using: :btree
  end

  create_table "cms_publish_urls", force: :cascade do |t|
    t.string   "name"
    t.integer  "publishable_id"
    t.string   "publishable_type"
    t.integer  "content_id"
    t.integer  "node_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "cms_publishers", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "publishable_id"
    t.string   "publishable_type"
    t.string   "state"
    t.integer  "priority"
    t.jsonb    "extra_flag",       default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["publishable_type", "publishable_id"], name: "index_cms_publishers_on_publishable_type_and_publishable_id", using: :btree
    t.index ["site_id"], name: "index_cms_publishers_on_site_id", using: :btree
  end

  create_table "cms_site_basic_auth_users", force: :cascade do |t|
    t.string   "state"
    t.integer  "site_id"
    t.string   "name"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "target_type"
    t.string   "target_location"
  end

  create_table "cms_site_belongings", force: :cascade do |t|
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.index ["group_id"], name: "index_cms_site_belongings_on_group_id", using: :btree
    t.index ["site_id"], name: "index_cms_site_belongings_on_site_id", using: :btree
  end

  create_table "cms_site_settings", force: :cascade do |t|
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "value"
    t.integer  "sort_no"
    t.index ["site_id", "name"], name: "index_cms_site_settings_on_site_id_and_name", using: :btree
  end

  create_table "cms_sites", force: :cascade do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "full_uri"
    t.string   "mobile_full_uri"
    t.integer  "node_id"
    t.text     "related_site"
    t.string   "map_key"
    t.string   "portal_group_state"
    t.integer  "portal_group_id"
    t.integer  "portal_category_ids"
    t.integer  "portal_business_ids"
    t.integer  "portal_attribute_ids"
    t.integer  "portal_area_ids"
    t.text     "body"
    t.integer  "site_image_id"
    t.string   "og_type"
    t.string   "og_title"
    t.text     "og_description"
    t.string   "og_image"
    t.string   "smart_phone_publication"
    t.string   "spp_target"
    t.string   "google_map_api_key"
    t.string   "admin_full_uri"
  end

  create_table "cms_stylesheets", force: :cascade do |t|
    t.integer  "concept_id"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path"
    t.index ["concept_id"], name: "index_cms_stylesheets_on_concept_id", using: :btree
    t.index ["site_id"], name: "index_cms_stylesheets_on_site_id", using: :btree
  end

  create_table "cms_talk_tasks", force: :cascade do |t|
    t.string   "dependent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "path"
    t.string   "content_hash"
    t.string   "talk_processable_type"
    t.integer  "talk_processable_id"
    t.integer  "site_id"
    t.index ["talk_processable_type", "talk_processable_id"], name: "index_cms_talk_tasks_on_talk_processable", using: :btree
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "feed_feed_entries", force: :cascade do |t|
    t.integer  "feed_id"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "entry_id"
    t.datetime "entry_updated"
    t.date     "event_date"
    t.text     "title"
    t.text     "summary"
    t.text     "link_alternate"
    t.text     "link_enclosure"
    t.text     "categories"
    t.text     "categories_xml"
    t.text     "image_uri"
    t.integer  "image_length"
    t.text     "image_type"
    t.text     "author_name"
    t.string   "author_email"
    t.text     "author_uri"
  end

  create_table "feed_feeds", force: :cascade do |t|
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                 null: false
    t.text     "uri"
    t.text     "title"
    t.string   "feed_id"
    t.string   "feed_type"
    t.datetime "feed_updated"
    t.text     "feed_title"
    t.text     "link_alternate"
    t.integer  "entry_count"
    t.text     "fixed_categories_xml"
  end

  create_table "gnav_category_sets", force: :cascade do |t|
    t.integer "menu_item_id"
    t.integer "category_id"
    t.string  "layer"
    t.index ["category_id"], name: "index_gnav_category_sets_on_category_id", using: :btree
    t.index ["menu_item_id"], name: "index_gnav_category_sets_on_menu_item_id", using: :btree
  end

  create_table "gnav_menu_items", force: :cascade do |t|
    t.integer  "content_id"
    t.integer  "concept_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "layout_id"
    t.string   "sitemap_state"
    t.index ["concept_id"], name: "index_gnav_menu_items_on_concept_id", using: :btree
    t.index ["content_id"], name: "index_gnav_menu_items_on_content_id", using: :btree
    t.index ["layout_id"], name: "index_gnav_menu_items_on_layout_id", using: :btree
  end

  create_table "gp_article_comments", force: :cascade do |t|
    t.integer  "doc_id"
    t.string   "state"
    t.string   "author_name"
    t.string   "author_email"
    t.string   "author_url"
    t.string   "remote_addr"
    t.string   "user_agent"
    t.text     "body"
    t.datetime "posted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["doc_id"], name: "index_gp_article_comments_on_doc_id", using: :btree
  end

  create_table "gp_article_docs", force: :cascade do |t|
    t.integer  "concept_id"
    t.integer  "content_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "href"
    t.string   "target"
    t.text     "subtitle"
    t.text     "summary"
    t.string   "name"
    t.datetime "published_at"
    t.datetime "recognized_at"
    t.string   "state"
    t.string   "event_state"
    t.text     "raw_tags"
    t.string   "mobile_title"
    t.text     "mobile_body"
    t.boolean  "terminal_pc_or_smart_phone"
    t.boolean  "terminal_mobile"
    t.string   "rel_doc_ids"
    t.datetime "display_published_at"
    t.datetime "display_updated_at"
    t.date     "event_started_on"
    t.date     "event_ended_on"
    t.string   "marker_state"
    t.text     "meta_description"
    t.string   "meta_keywords"
    t.string   "list_image"
    t.integer  "prev_edition_id"
    t.integer  "template_id"
    t.text     "template_values"
    t.string   "og_type"
    t.string   "og_title"
    t.text     "og_description"
    t.string   "og_image"
    t.string   "share_to_sns_with"
    t.text     "body_more"
    t.string   "body_more_link_text"
    t.boolean  "feature_1"
    t.boolean  "feature_2"
    t.string   "filename_base"
    t.integer  "marker_icon_category_id"
    t.boolean  "keep_display_updated_at"
    t.integer  "layout_id"
    t.text     "qrcode_state"
    t.string   "event_will_sync"
    t.integer  "serial_no"
    t.string   "lang"
    t.text     "event_note"
    t.index ["concept_id"], name: "index_gp_article_docs_on_concept_id", using: :btree
    t.index ["content_id"], name: "index_gp_article_docs_on_content_id", using: :btree
    t.index ["event_started_on", "event_ended_on"], name: "index_gp_article_docs_on_event_started_on_and_event_ended_on", using: :btree
    t.index ["event_state"], name: "index_gp_article_docs_on_event_state", using: :btree
    t.index ["state"], name: "index_gp_article_docs_on_state", using: :btree
    t.index ["terminal_pc_or_smart_phone"], name: "index_gp_article_docs_on_terminal_pc_or_smart_phone", using: :btree
  end

  create_table "gp_article_docs_tag_tags", force: :cascade do |t|
    t.integer "doc_id"
    t.integer "tag_id"
  end

  create_table "gp_article_holds", force: :cascade do |t|
    t.integer  "holdable_id"
    t.string   "holdable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gp_article_links", force: :cascade do |t|
    t.integer  "doc_id"
    t.string   "body"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gp_article_related_docs", force: :cascade do |t|
    t.integer  "content_id"
    t.integer  "relatable_id"
    t.string   "relatable_type"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "gp_calendar_events", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "state"
    t.date     "started_on"
    t.date     "ended_on"
    t.string   "name"
    t.string   "title"
    t.string   "href"
    t.string   "target"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sync_source_host"
    t.integer  "sync_source_content_id"
    t.string   "sync_source_id"
    t.string   "sync_source_source_class"
    t.string   "will_sync"
    t.text     "note"
    t.index ["content_id"], name: "index_gp_calendar_events_on_content_id", using: :btree
    t.index ["started_on", "ended_on"], name: "index_gp_calendar_events_on_started_on_and_ended_on", using: :btree
    t.index ["state"], name: "index_gp_calendar_events_on_state", using: :btree
  end

  create_table "gp_calendar_events_gp_category_categories", force: :cascade do |t|
    t.integer "event_id"
    t.integer "category_id"
  end

  create_table "gp_calendar_holidays", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "state"
    t.string   "title"
    t.date     "date"
    t.text     "description"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "repeat"
    t.string   "sync_source_host"
    t.integer  "sync_source_content_id"
    t.integer  "sync_source_id"
  end

  create_table "gp_category_categories", force: :cascade do |t|
    t.integer  "concept_id"
    t.integer  "layout_id"
    t.integer  "category_type_id"
    t.integer  "parent_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.integer  "level_no"
    t.integer  "sort_no"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_code"
    t.string   "sitemap_state"
    t.string   "docs_order"
    t.integer  "template_id"
    t.integer  "children_count",   default: 0, null: false
    t.index ["category_type_id"], name: "index_gp_category_categories_on_category_type_id", using: :btree
    t.index ["concept_id"], name: "index_gp_category_categories_on_concept_id", using: :btree
    t.index ["layout_id"], name: "index_gp_category_categories_on_layout_id", using: :btree
    t.index ["parent_id"], name: "index_gp_category_categories_on_parent_id", using: :btree
    t.index ["state"], name: "index_gp_category_categories_on_state", using: :btree
  end

  create_table "gp_category_categorizations", force: :cascade do |t|
    t.integer  "categorizable_id"
    t.string   "categorizable_type"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.string   "categorized_as"
    t.index ["categorizable_id", "categorizable_type"], name: "index_gp_category_categorizations_on_categorizable_id_and_type", using: :btree
    t.index ["categorized_as"], name: "index_gp_category_categorizations_on_categorized_as", using: :btree
    t.index ["category_id"], name: "index_gp_category_categorizations_on_category_id", using: :btree
  end

  create_table "gp_category_category_types", force: :cascade do |t|
    t.integer  "content_id"
    t.integer  "concept_id"
    t.integer  "layout_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sitemap_state"
    t.string   "docs_order"
    t.integer  "template_id"
    t.integer  "internal_category_type_id"
    t.string   "description"
    t.index ["concept_id"], name: "index_gp_category_category_types_on_concept_id", using: :btree
    t.index ["content_id"], name: "index_gp_category_category_types_on_content_id", using: :btree
    t.index ["layout_id"], name: "index_gp_category_category_types_on_layout_id", using: :btree
  end

  create_table "gp_category_publishers", force: :cascade do |t|
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_id"], name: "index_gp_category_publishers_on_category_id", using: :btree
  end

  create_table "gp_category_template_modules", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "name"
    t.string   "title"
    t.string   "module_type"
    t.string   "module_type_feature"
    t.string   "wrapper_tag"
    t.text     "doc_style"
    t.integer  "num_docs"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "upper_text"
    t.text     "lower_text"
    t.index ["content_id"], name: "index_gp_category_template_modules_on_content_id", using: :btree
  end

  create_table "gp_category_templates", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "name"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["content_id"], name: "index_gp_category_templates_on_content_id", using: :btree
  end

  create_table "gp_template_items", force: :cascade do |t|
    t.integer  "template_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.string   "item_type"
    t.text     "item_options"
    t.string   "style_attribute"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["template_id"], name: "index_gp_template_items_on_template_id", using: :btree
  end

  create_table "gp_template_templates", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "state"
    t.string   "title"
    t.text     "body"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["content_id"], name: "index_gp_template_templates_on_content_id", using: :btree
  end

  create_table "map_marker_icons", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "relatable_type"
    t.integer  "relatable_id"
    t.string   "url"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["content_id"], name: "index_map_marker_icons_on_content_id", using: :btree
    t.index ["relatable_type", "relatable_id"], name: "index_map_marker_icons_on_relatable_type_and_relatable_id", using: :btree
  end

  create_table "map_markers", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "state"
    t.string   "title"
    t.string   "latitude"
    t.string   "longitude"
    t.text     "window_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "icon_category_id"
  end

  create_table "organization_groups", force: :cascade do |t|
    t.integer  "concept_id"
    t.integer  "layout_id"
    t.integer  "content_id"
    t.string   "state"
    t.string   "name"
    t.string   "sys_group_code"
    t.string   "sitemap_state"
    t.string   "docs_order"
    t.integer  "sort_no"
    t.text     "business_outline"
    t.text     "contact_information"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "more_layout_id"
    t.text     "outline"
    t.index ["sys_group_code"], name: "index_organization_groups_on_sys_group_code", using: :btree
  end

  create_table "rank_categories", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "page_path"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rank_ranks", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "page_title"
    t.string   "hostname"
    t.string   "page_path"
    t.date     "date"
    t.integer  "pageviews"
    t.integer  "visitors"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rank_totals", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "term"
    t.string   "page_title"
    t.string   "hostname"
    t.string   "page_path"
    t.integer  "pageviews"
    t.integer  "visitors"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "idx_key", using: :btree
  end

  create_table "sns_share_accounts", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "info_nickname"
    t.string   "info_name"
    t.string   "info_image"
    t.string   "info_url"
    t.string   "credential_token"
    t.string   "credential_expires_at"
    t.string   "credential_secret"
    t.text     "facebook_page_options"
    t.string   "facebook_page"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "facebook_token_options"
    t.string   "facebook_token"
    t.index ["content_id"], name: "index_sns_share_accounts_on_content_id", using: :btree
  end

  create_table "sns_share_shares", force: :cascade do |t|
    t.integer  "sharable_id"
    t.string   "sharable_type"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sharable_type", "sharable_id"], name: "index_sns_share_shares_on_sharable_type_and_sharable_id", using: :btree
  end

  create_table "survey_answers", force: :cascade do |t|
    t.integer  "form_answer_id"
    t.integer  "question_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["form_answer_id"], name: "index_survey_answers_on_form_answer_id", using: :btree
    t.index ["question_id"], name: "index_survey_answers_on_question_id", using: :btree
  end

  create_table "survey_form_answers", force: :cascade do |t|
    t.integer  "form_id"
    t.string   "answered_url"
    t.string   "remote_addr"
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "answered_url_title"
    t.index ["form_id"], name: "index_survey_form_answers_on_form_id", using: :btree
  end

  create_table "survey_forms", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.integer  "sort_no"
    t.text     "summary"
    t.text     "description"
    t.text     "receipt"
    t.boolean  "confirmation"
    t.string   "sitemap_state"
    t.string   "index_link"
    t.index ["content_id"], name: "index_survey_forms_on_content_id", using: :btree
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer  "form_id"
    t.string   "state"
    t.string   "title"
    t.text     "description"
    t.string   "form_type"
    t.text     "form_options"
    t.boolean  "required"
    t.string   "style_attribute"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "form_text_max_length"
    t.index ["form_id"], name: "index_survey_questions_on_form_id", using: :btree
  end

  create_table "sys_cache_sweepers", force: :cascade do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model"
    t.text     "uri"
    t.text     "options"
    t.index ["model", "uri"], name: "model", using: :btree
  end

  create_table "sys_closers", force: :cascade do |t|
    t.string   "dependent"
    t.string   "path"
    t.string   "content_hash"
    t.datetime "published_at"
    t.datetime "republished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sys_creators", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "creatable_id"
    t.string   "creatable_type"
    t.index ["creatable_type", "creatable_id"], name: "index_sys_creators_on_creatable_type_and_creatable_id", using: :btree
  end

  create_table "sys_editable_groups", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "group_ids"
    t.boolean  "all"
    t.integer  "editable_id"
    t.string   "editable_type"
    t.integer  "group_id"
    t.index ["editable_type", "editable_id"], name: "index_sys_editable_groups_on_editable_type_and_editable_id", using: :btree
    t.index ["group_id"], name: "index_sys_editable_groups_on_group_id", using: :btree
  end

  create_table "sys_editors", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "editable_id"
    t.string   "editable_type"
    t.index ["editable_type", "editable_id"], name: "index_sys_editors_on_editable_type_and_editable_id", using: :btree
  end

  create_table "sys_files", force: :cascade do |t|
    t.string   "tmp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "title"
    t.text     "mime_type"
    t.integer  "size"
    t.integer  "image_is"
    t.integer  "image_width"
    t.integer  "image_height"
    t.integer  "file_attachable_id"
    t.string   "file_attachable_type"
    t.integer  "site_id"
    t.integer  "thumb_width"
    t.integer  "thumb_height"
    t.integer  "thumb_size"
    t.text     "extracted_text"
    t.index ["file_attachable_type", "file_attachable_id"], name: "index_sys_files_on_file_attachable_type_and_file_attachable_id", using: :btree
  end

  create_table "sys_groups", force: :cascade do |t|
    t.string   "state"
    t.string   "web_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",    null: false
    t.integer  "level_no"
    t.string   "code",         null: false
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.integer  "ldap",         null: false
    t.string   "ldap_version"
    t.string   "name"
    t.string   "name_en"
    t.string   "tel"
    t.string   "outline_uri"
    t.string   "email"
    t.string   "fax"
    t.string   "address"
    t.string   "note"
    t.string   "tel_attend"
    t.index ["code"], name: "index_sys_groups_on_code", using: :btree
    t.index ["parent_id"], name: "index_sys_groups_on_parent_id", using: :btree
    t.index ["state"], name: "index_sys_groups_on_state", using: :btree
  end

  create_table "sys_languages", force: :cascade do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.string   "name"
    t.text     "title"
  end

  create_table "sys_ldap_synchros", force: :cascade do |t|
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version"
    t.string   "entry_type"
    t.string   "code"
    t.integer  "sort_no"
    t.string   "name"
    t.string   "name_en"
    t.string   "email"
    t.index ["version", "parent_id", "entry_type"], name: "index_sys_ldap_synchros_on_version_and_parent_id_and_entry_type", using: :btree
  end

  create_table "sys_maintenances", force: :cascade do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title"
    t.text     "body"
    t.integer  "site_id"
  end

  create_table "sys_messages", force: :cascade do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title"
    t.text     "body"
    t.integer  "site_id"
  end

  create_table "sys_object_privileges", force: :cascade do |t|
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
    t.integer  "privilegable_id"
    t.string   "privilegable_type"
    t.integer  "concept_id"
    t.index ["concept_id"], name: "index_sys_object_privileges_on_concept_id", using: :btree
    t.index ["privilegable_type", "privilegable_id"], name: "index_sys_object_privileges_on_privilegable", using: :btree
  end

  create_table "sys_object_relations", force: :cascade do |t|
    t.integer "source_id"
    t.string  "source_type"
    t.integer "related_id"
    t.string  "related_type"
    t.string  "relation_type"
    t.index ["related_type", "related_id"], name: "index_sys_object_relations_on_related_type_and_related_id", using: :btree
    t.index ["source_type", "source_id"], name: "index_sys_object_relations_on_source_type_and_source_id", using: :btree
  end

  create_table "sys_operation_logs", force: :cascade do |t|
    t.integer  "loggable_id"
    t.string   "loggable_type"
    t.integer  "user_id"
    t.string   "operation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_name"
    t.string   "ipaddr"
    t.string   "uri"
    t.string   "action"
    t.string   "item_model"
    t.integer  "item_id"
    t.string   "item_name"
    t.integer  "site_id"
  end

  create_table "sys_process_logs", force: :cascade do |t|
    t.integer  "process_id"
    t.datetime "started_at"
    t.datetime "closed_at"
    t.integer  "user_id"
    t.string   "state"
    t.string   "name"
    t.string   "interrupt"
    t.integer  "total"
    t.integer  "current"
    t.integer  "success"
    t.integer  "error"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "site_id"
  end

  create_table "sys_processes", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "closed_at"
    t.integer  "user_id"
    t.string   "state"
    t.string   "name"
    t.string   "interrupt"
    t.integer  "total"
    t.integer  "current"
    t.integer  "success"
    t.integer  "error"
    t.text     "message"
    t.integer  "site_id"
  end

  create_table "sys_publishers", force: :cascade do |t|
    t.string   "dependent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path"
    t.string   "content_hash"
    t.integer  "publishable_id"
    t.string   "publishable_type"
    t.index ["publishable_type", "publishable_id"], name: "index_sys_publishers_on_publishable_type_and_publishable_id", using: :btree
  end

  create_table "sys_recognitions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "recognizer_ids"
    t.text     "info_xml"
    t.integer  "recognizable_id"
    t.string   "recognizable_type"
    t.index ["recognizable_type", "recognizable_id"], name: "index_sys_recognitions_on_recognizable", using: :btree
    t.index ["user_id"], name: "index_sys_recognitions_on_user_id", using: :btree
  end

  create_table "sys_role_names", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "title"
    t.integer  "site_id"
  end

  create_table "sys_sequences", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "version"
    t.integer  "value"
    t.index ["name", "version"], name: "index_sys_sequences_on_name_and_version", unique: true, using: :btree
  end

  create_table "sys_settings", force: :cascade do |t|
    t.string   "name"
    t.text     "value"
    t.integer  "sort_no"
    t.text     "extra_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sys_tasks", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "process_at"
    t.string   "name"
    t.integer  "processable_id"
    t.string   "processable_type"
    t.integer  "site_id"
    t.index ["processable_type", "processable_id"], name: "index_sys_tasks_on_processable_type_and_processable_id", using: :btree
  end

  create_table "sys_temp_texts", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sys_transferable_files", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.integer  "version"
    t.string   "operation"
    t.string   "file_type"
    t.string   "parent_dir"
    t.string   "path"
    t.string   "destination"
    t.integer  "operator_id"
    t.string   "operator_name"
    t.datetime "operated_at"
    t.integer  "item_id"
    t.integer  "item_unid"
    t.string   "item_model"
    t.string   "item_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "operator_id"], name: "index_sys_transferable_files_on_user_id_and_operator_id", using: :btree
  end

  create_table "sys_transferred_files", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "version"
    t.string   "operation"
    t.string   "file_type"
    t.string   "parent_dir"
    t.string   "path"
    t.string   "destination"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "operator_id"
    t.string   "operator_name"
    t.datetime "operated_at"
    t.integer  "item_id"
    t.integer  "item_unid"
    t.string   "item_model"
    t.string   "item_name"
    t.index ["created_at"], name: "index_sys_transferred_files_on_created_at", using: :btree
    t.index ["operator_id"], name: "index_sys_transferred_files_on_operator_id", using: :btree
    t.index ["user_id"], name: "index_sys_transferred_files_on_user_id", using: :btree
    t.index ["version"], name: "index_sys_transferred_files_on_version", using: :btree
  end

  create_table "sys_unid_relations", force: :cascade do |t|
    t.integer "unid",     null: false
    t.integer "rel_unid", null: false
    t.string  "rel_type", null: false
    t.index ["rel_unid"], name: "index_sys_unid_relations_on_rel_unid", using: :btree
    t.index ["unid"], name: "index_sys_unid_relations_on_unid", using: :btree
  end

  create_table "sys_unids", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model",      null: false
    t.integer  "item_id"
  end

  create_table "sys_users", force: :cascade do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ldap",                                            null: false
    t.string   "ldap_version"
    t.integer  "auth_no",                                         null: false
    t.string   "name"
    t.string   "name_en"
    t.string   "account"
    t.string   "password"
    t.string   "email"
    t.text     "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "admin_creatable",                 default: false
    t.boolean  "site_creatable",                  default: false
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
  end

  create_table "sys_users_groups", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.index ["user_id", "group_id"], name: "index_sys_users_groups_on_user_id_and_group_id", using: :btree
  end

  create_table "sys_users_roles", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_sys_users_roles_on_user_id_and_role_id", using: :btree
  end

  create_table "tag_tags", force: :cascade do |t|
    t.integer  "content_id"
    t.text     "word"
    t.datetime "last_tagged_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["content_id"], name: "index_tag_tags_on_content_id", using: :btree
  end

  create_table "tool_convert_docs", force: :cascade do |t|
    t.string   "file_path"
    t.text     "uri_path"
    t.text     "site_url"
    t.text     "title"
    t.datetime "published_at"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "content_id"
    t.integer  "docable_id"
    t.string   "docable_type"
    t.text     "doc_name"
    t.text     "doc_public_uri"
    t.string   "page_updated_at"
    t.string   "page_group_code"
    t.index ["content_id"], name: "index_tool_convert_docs_on_content_id", using: :btree
    t.index ["docable_id", "docable_type"], name: "index_tool_convert_docs_on_docable_id_and_docable_type", using: :btree
    t.index ["uri_path"], name: "index_tool_convert_docs_on_uri_path", using: :btree
  end

  create_table "tool_convert_downloads", force: :cascade do |t|
    t.string   "state"
    t.text     "site_url"
    t.text     "include_dir"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "remark"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recursive_level"
  end

  create_table "tool_convert_imports", force: :cascade do |t|
    t.string   "state"
    t.text     "site_url"
    t.string   "site_filename"
    t.integer  "content_id"
    t.integer  "overwrite"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "message"
    t.integer  "total_num"
    t.integer  "created_num"
    t.integer  "updated_num"
    t.integer  "nonupdated_num"
    t.integer  "skipped_num"
    t.integer  "link_total_num"
    t.integer  "link_processed_num"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "keep_filename"
  end

  create_table "tool_convert_links", force: :cascade do |t|
    t.integer  "concept_id"
    t.integer  "linkable_id"
    t.string   "linkable_type"
    t.text     "urls"
    t.text     "before_body"
    t.text     "after_body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tool_convert_settings", force: :cascade do |t|
    t.string   "site_url"
    t.text     "title_tag"
    t.text     "body_tag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "updated_at_tag"
    t.text     "updated_at_regexp"
    t.text     "creator_group_from_url_regexp"
    t.text     "category_tag"
    t.text     "category_regexp"
    t.integer  "creator_group_relation_type"
    t.text     "creator_group_url_relations"
    t.index ["site_url"], name: "index_tool_convert_settings_on_site_url", using: :btree
  end

  create_table "tool_simple_captcha_data", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
