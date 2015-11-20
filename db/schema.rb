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

ActiveRecord::Schema.define(version: 20151118044706) do

  create_table "ad_banner_banners", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "title",              limit: 255
    t.string   "mime_type",          limit: 255
    t.integer  "size",               limit: 4
    t.integer  "image_is",           limit: 4
    t.integer  "image_width",        limit: 4
    t.integer  "image_height",       limit: 4
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.integer  "group_id",           limit: 4
    t.string   "state",              limit: 255
    t.string   "advertiser_name",    limit: 255
    t.string   "advertiser_phone",   limit: 255
    t.string   "advertiser_email",   limit: 255
    t.string   "advertiser_contact", limit: 255
    t.datetime "published_at"
    t.datetime "closed_at"
    t.string   "url",                limit: 255
    t.integer  "sort_no",            limit: 4
    t.string   "token",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "target",             limit: 65535
  end

  add_index "ad_banner_banners", ["token"], name: "index_ad_banner_banners_on_token", unique: true, using: :btree

  create_table "ad_banner_clicks", force: :cascade do |t|
    t.integer  "banner_id",   limit: 4
    t.string   "referer",     limit: 255
    t.string   "remote_addr", limit: 255
    t.string   "user_agent",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ad_banner_groups", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.string   "name",       limit: 255
    t.string   "title",      limit: 255
    t.integer  "sort_no",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_approval_flows", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.string   "title",      limit: 255
    t.integer  "group_id",   limit: 4
    t.integer  "sort_no",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "approval_approval_request_histories", force: :cascade do |t|
    t.integer  "request_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "reason",     limit: 255
    t.text     "comment",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "approval_approval_request_histories", ["request_id"], name: "index_approval_approval_request_histories_on_request_id", using: :btree
  add_index "approval_approval_request_histories", ["user_id"], name: "index_approval_approval_request_histories_on_user_id", using: :btree

  create_table "approval_approval_requests", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.integer  "approval_flow_id",   limit: 4
    t.integer  "approvable_id",      limit: 4
    t.string   "approvable_type",    limit: 255
    t.integer  "current_index",      limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "select_assignments", limit: 65535
  end

  create_table "approval_approvals", force: :cascade do |t|
    t.integer  "approval_flow_id", limit: 4
    t.integer  "index",            limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "approval_type",    limit: 65535
  end

  create_table "approval_assignments", force: :cascade do |t|
    t.integer  "assignable_id",   limit: 4
    t.string   "assignable_type", limit: 255
    t.integer  "user_id",         limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "approved_at"
    t.integer  "or_group_id",     limit: 4
  end

  add_index "approval_assignments", ["assignable_type", "assignable_id"], name: "index_approval_assignments_on_assignable_type_and_assignable_id", using: :btree
  add_index "approval_assignments", ["user_id"], name: "index_approval_assignments_on_user_id", using: :btree

  create_table "biz_calendar_bussiness_holidays", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "place_id",           limit: 4
    t.string   "state",              limit: 255
    t.integer  "type_id",            limit: 4
    t.date     "holiday_start_date"
    t.date     "holiday_end_date"
    t.string   "repeat_type",        limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "end_type",           limit: 4
    t.integer  "end_times",          limit: 4
    t.integer  "repeat_interval",    limit: 4
    t.text     "repeat_week",        limit: 65535
    t.text     "repeat_criterion",   limit: 65535
  end

  create_table "biz_calendar_bussiness_hours", force: :cascade do |t|
    t.integer  "unid",                      limit: 4
    t.integer  "place_id",                  limit: 4
    t.string   "state",                     limit: 255
    t.date     "fixed_start_date"
    t.date     "fixed_end_date"
    t.string   "repeat_type",               limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.time     "business_hours_start_time"
    t.time     "business_hours_end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "end_type",                  limit: 4
    t.integer  "end_times",                 limit: 4
    t.integer  "repeat_interval",           limit: 4
    t.text     "repeat_week",               limit: 65535
    t.text     "repeat_criterion",          limit: 65535
  end

  create_table "biz_calendar_exception_holidays", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "place_id",   limit: 4
    t.string   "state",      limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biz_calendar_holiday_types", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.string   "state",      limit: 255
    t.string   "name",       limit: 255
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_calendar_holiday_types", ["content_id"], name: "index_biz_calendar_holiday_types_on_content_id", using: :btree

  create_table "biz_calendar_places", force: :cascade do |t|
    t.integer  "unid",                   limit: 4
    t.integer  "content_id",             limit: 4
    t.string   "state",                  limit: 255
    t.string   "url",                    limit: 255
    t.string   "title",                  limit: 255
    t.string   "summary",                limit: 255
    t.string   "description",            limit: 255
    t.string   "business_hours_state",   limit: 255
    t.string   "business_hours_title",   limit: 255
    t.string   "business_holiday_state", limit: 255
    t.string   "business_holiday_title", limit: 255
    t.integer  "sort_no",                limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_calendar_places", ["content_id"], name: "index_biz_calendar_places_on_content_id", using: :btree

  create_table "cms_concepts", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "parent_id",  limit: 4
    t.integer  "site_id",    limit: 4
    t.string   "state",      limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",   limit: 4,   null: false
    t.integer  "sort_no",    limit: 4
    t.string   "name",       limit: 255
  end

  add_index "cms_concepts", ["parent_id", "state", "sort_no"], name: "parent_id", using: :btree

  create_table "cms_content_settings", force: :cascade do |t|
    t.integer  "content_id",  limit: 4,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",        limit: 255
    t.text     "value",       limit: 65535
    t.integer  "sort_no",     limit: 4
    t.text     "extra_value", limit: 65535
  end

  add_index "cms_content_settings", ["content_id"], name: "content_id", using: :btree

  create_table "cms_contents", force: :cascade do |t|
    t.integer  "unid",           limit: 4
    t.integer  "site_id",        limit: 4,          null: false
    t.integer  "concept_id",     limit: 4
    t.string   "state",          limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model",          limit: 255
    t.string   "name",           limit: 255
    t.text     "xml_properties", limit: 4294967295
    t.string   "note",           limit: 255
    t.string   "code",           limit: 255
    t.integer  "sort_no",        limit: 4
  end

  create_table "cms_data_file_nodes", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "site_id",    limit: 4
    t.integer  "concept_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
    t.text     "title",      limit: 65535
  end

  add_index "cms_data_file_nodes", ["concept_id", "name"], name: "concept_id", using: :btree

  create_table "cms_data_files", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.integer  "site_id",      limit: 4
    t.integer  "concept_id",   limit: 4
    t.integer  "node_id",      limit: 4
    t.string   "state",        limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "name",         limit: 255
    t.text     "title",        limit: 65535
    t.text     "mime_type",    limit: 65535
    t.integer  "size",         limit: 4
    t.integer  "image_is",     limit: 4
    t.integer  "image_width",  limit: 4
    t.integer  "image_height", limit: 4
  end

  add_index "cms_data_files", ["concept_id", "node_id", "name"], name: "concept_id", using: :btree

  create_table "cms_data_texts", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.integer  "site_id",      limit: 4
    t.integer  "concept_id",   limit: 4
    t.string   "state",        limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "name",         limit: 255
    t.text     "title",        limit: 65535
    t.text     "body",         limit: 4294967295
  end

  create_table "cms_feed_entries", force: :cascade do |t|
    t.integer  "feed_id",        limit: 4
    t.integer  "content_id",     limit: 4
    t.text     "state",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "entry_id",       limit: 255
    t.datetime "entry_updated"
    t.date     "event_date"
    t.text     "title",          limit: 65535
    t.text     "summary",        limit: 4294967295
    t.text     "link_alternate", limit: 65535
    t.text     "link_enclosure", limit: 65535
    t.text     "categories",     limit: 65535
    t.text     "author_name",    limit: 65535
    t.string   "author_email",   limit: 255
    t.text     "author_uri",     limit: 65535
  end

  add_index "cms_feed_entries", ["feed_id", "content_id", "entry_updated"], name: "feed_id", using: :btree

  create_table "cms_feeds", force: :cascade do |t|
    t.integer  "unid",           limit: 4
    t.integer  "content_id",     limit: 4
    t.text     "state",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",           limit: 255,   null: false
    t.text     "uri",            limit: 65535
    t.text     "title",          limit: 65535
    t.string   "feed_id",        limit: 255
    t.string   "feed_type",      limit: 255
    t.datetime "feed_updated"
    t.text     "feed_title",     limit: 65535
    t.text     "link_alternate", limit: 65535
    t.integer  "entry_count",    limit: 4
  end

  create_table "cms_inquiries", force: :cascade do |t|
    t.integer  "parent_unid", limit: 4
    t.string   "state",       limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     limit: 4
    t.integer  "group_id",    limit: 4
    t.text     "charge",      limit: 65535
    t.text     "tel",         limit: 65535
    t.text     "fax",         limit: 65535
    t.text     "email",       limit: 65535
  end

  add_index "cms_inquiries", ["parent_unid"], name: "index_cms_inquiries_on_parent_unid", using: :btree

  create_table "cms_kana_dictionaries", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "site_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
    t.text     "body",       limit: 4294967295
    t.text     "mecab_csv",  limit: 4294967295
  end

  create_table "cms_layouts", force: :cascade do |t|
    t.integer  "unid",                   limit: 4
    t.integer  "concept_id",             limit: 4
    t.integer  "template_id",            limit: 4
    t.integer  "site_id",                limit: 4,          null: false
    t.string   "state",                  limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.string   "name",                   limit: 255
    t.text     "title",                  limit: 65535
    t.text     "head",                   limit: 4294967295
    t.text     "body",                   limit: 4294967295
    t.text     "stylesheet",             limit: 4294967295
    t.text     "mobile_head",            limit: 65535
    t.text     "mobile_body",            limit: 4294967295
    t.text     "mobile_stylesheet",      limit: 4294967295
    t.text     "smart_phone_head",       limit: 65535
    t.text     "smart_phone_body",       limit: 4294967295
    t.text     "smart_phone_stylesheet", limit: 4294967295
  end

  create_table "cms_link_check_logs", force: :cascade do |t|
    t.integer  "link_check_id",       limit: 4
    t.integer  "link_checkable_id",   limit: 4
    t.string   "link_checkable_type", limit: 255
    t.boolean  "checked"
    t.string   "title",               limit: 255
    t.string   "body",                limit: 255
    t.string   "url",                 limit: 255
    t.integer  "status",              limit: 4
    t.string   "reason",              limit: 255
    t.boolean  "result"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "cms_link_checks", force: :cascade do |t|
    t.boolean  "in_progress"
    t.boolean  "checked"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "cms_map_markers", force: :cascade do |t|
    t.integer  "map_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no",    limit: 4
    t.string   "name",       limit: 255
    t.string   "lat",        limit: 255
    t.string   "lng",        limit: 255
  end

  add_index "cms_map_markers", ["map_id"], name: "map_id", using: :btree

  create_table "cms_maps", force: :cascade do |t|
    t.integer  "unid",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",        limit: 255
    t.text     "title",       limit: 65535
    t.text     "map_lat",     limit: 65535
    t.text     "map_lng",     limit: 65535
    t.text     "map_zoom",    limit: 65535
    t.text     "point1_name", limit: 65535
    t.text     "point1_lat",  limit: 65535
    t.text     "point1_lng",  limit: 65535
    t.text     "point2_name", limit: 65535
    t.text     "point2_lat",  limit: 65535
    t.text     "point2_lng",  limit: 65535
    t.text     "point3_name", limit: 65535
    t.text     "point3_lat",  limit: 65535
    t.text     "point3_lng",  limit: 65535
    t.text     "point4_name", limit: 65535
    t.text     "point4_lat",  limit: 65535
    t.text     "point4_lng",  limit: 65535
    t.text     "point5_name", limit: 65535
    t.text     "point5_lat",  limit: 65535
    t.text     "point5_lng",  limit: 65535
  end

  create_table "cms_nodes", force: :cascade do |t|
    t.integer  "unid",            limit: 4
    t.integer  "concept_id",      limit: 4
    t.integer  "site_id",         limit: 4
    t.string   "state",           limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "parent_id",       limit: 4
    t.integer  "route_id",        limit: 4
    t.integer  "content_id",      limit: 4
    t.string   "model",           limit: 255
    t.integer  "directory",       limit: 4
    t.integer  "layout_id",       limit: 4
    t.string   "name",            limit: 255
    t.text     "title",           limit: 65535
    t.text     "body",            limit: 4294967295
    t.text     "mobile_title",    limit: 65535
    t.text     "mobile_body",     limit: 4294967295
    t.string   "sitemap_state",   limit: 255
    t.integer  "sitemap_sort_no", limit: 4
  end

  add_index "cms_nodes", ["concept_id"], name: "index_cms_nodes_on_concept_id", using: :btree
  add_index "cms_nodes", ["content_id"], name: "index_cms_nodes_on_content_id", using: :btree
  add_index "cms_nodes", ["layout_id"], name: "index_cms_nodes_on_layout_id", using: :btree
  add_index "cms_nodes", ["parent_id", "name"], name: "parent_id", using: :btree
  add_index "cms_nodes", ["parent_id"], name: "index_cms_nodes_on_parent_id", using: :btree
  add_index "cms_nodes", ["route_id"], name: "index_cms_nodes_on_route_id", using: :btree
  add_index "cms_nodes", ["site_id"], name: "index_cms_nodes_on_site_id", using: :btree
  add_index "cms_nodes", ["state"], name: "index_cms_nodes_on_state", using: :btree

  create_table "cms_o_auth_users", force: :cascade do |t|
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "name",       limit: 255
    t.string   "image",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname",   limit: 255
    t.string   "url",        limit: 255
  end

  create_table "cms_piece_link_items", force: :cascade do |t|
    t.integer  "piece_id",   limit: 4,     null: false
    t.string   "state",      limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
    t.text     "body",       limit: 65535
    t.string   "uri",        limit: 255
    t.integer  "sort_no",    limit: 4
    t.string   "target",     limit: 255
  end

  add_index "cms_piece_link_items", ["piece_id"], name: "piece_id", using: :btree

  create_table "cms_piece_settings", force: :cascade do |t|
    t.integer  "piece_id",    limit: 4,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",        limit: 255
    t.text     "value",       limit: 65535
    t.integer  "sort_no",     limit: 4
    t.text     "extra_value", limit: 65535
  end

  add_index "cms_piece_settings", ["piece_id"], name: "piece_id", using: :btree

  create_table "cms_pieces", force: :cascade do |t|
    t.integer  "unid",           limit: 4
    t.integer  "concept_id",     limit: 4
    t.integer  "site_id",        limit: 4,          null: false
    t.string   "state",          limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "content_id",     limit: 4
    t.string   "model",          limit: 255
    t.string   "name",           limit: 255
    t.text     "title",          limit: 65535
    t.string   "view_title",     limit: 255
    t.text     "head",           limit: 4294967295
    t.text     "body",           limit: 4294967295
    t.text     "xml_properties", limit: 4294967295
    t.text     "etcetera",       limit: 16777215
  end

  add_index "cms_pieces", ["concept_id", "name", "state"], name: "concept_id", using: :btree

  create_table "cms_site_basic_auth_users", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.string   "state",      limit: 255
    t.integer  "site_id",    limit: 4
    t.string   "name",       limit: 255
    t.string   "password",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_site_belongings", force: :cascade do |t|
    t.integer  "site_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",   limit: 4
  end

  add_index "cms_site_belongings", ["group_id"], name: "index_cms_site_belongings_on_group_id", using: :btree
  add_index "cms_site_belongings", ["site_id"], name: "index_cms_site_belongings_on_site_id", using: :btree

  create_table "cms_site_settings", force: :cascade do |t|
    t.integer  "site_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 32
    t.text     "value",      limit: 65535
    t.integer  "sort_no",    limit: 4
  end

  add_index "cms_site_settings", ["site_id", "name"], name: "concept_id", using: :btree

  create_table "cms_sites", force: :cascade do |t|
    t.integer  "unid",                    limit: 4
    t.string   "state",                   limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                    limit: 255
    t.string   "full_uri",                limit: 255
    t.string   "mobile_full_uri",         limit: 255
    t.integer  "node_id",                 limit: 4
    t.text     "related_site",            limit: 65535
    t.string   "map_key",                 limit: 255
    t.integer  "portal_group_id",         limit: 4
    t.integer  "portal_category_ids",     limit: 4
    t.integer  "portal_business_ids",     limit: 4
    t.integer  "portal_attribute_ids",    limit: 4
    t.integer  "portal_area_ids",         limit: 4
    t.text     "body",                    limit: 65535
    t.integer  "site_image_id",           limit: 4
    t.string   "portal_group_state",      limit: 255
    t.string   "og_type",                 limit: 255
    t.string   "og_title",                limit: 255
    t.text     "og_description",          limit: 65535
    t.string   "og_image",                limit: 255
    t.string   "smart_phone_publication", limit: 255
    t.string   "spp_target",              limit: 255
  end

  create_table "cms_talk_tasks", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.string   "dependent",    limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "path",         limit: 65535
    t.string   "content_hash", limit: 255
  end

  add_index "cms_talk_tasks", ["unid", "dependent"], name: "unid", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "gnav_category_sets", force: :cascade do |t|
    t.integer "menu_item_id", limit: 4
    t.integer "category_id",  limit: 4
    t.string  "layer",        limit: 255
  end

  add_index "gnav_category_sets", ["category_id"], name: "index_gnav_category_sets_on_category_id", using: :btree
  add_index "gnav_category_sets", ["menu_item_id"], name: "index_gnav_category_sets_on_menu_item_id", using: :btree

  create_table "gnav_menu_items", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.integer  "content_id",    limit: 4
    t.integer  "concept_id",    limit: 4
    t.string   "state",         limit: 255
    t.string   "name",          limit: 255
    t.string   "title",         limit: 255
    t.integer  "sort_no",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "layout_id",     limit: 4
    t.string   "sitemap_state", limit: 255
  end

  add_index "gnav_menu_items", ["concept_id"], name: "index_gnav_menu_items_on_concept_id", using: :btree
  add_index "gnav_menu_items", ["content_id"], name: "index_gnav_menu_items_on_content_id", using: :btree
  add_index "gnav_menu_items", ["layout_id"], name: "index_gnav_menu_items_on_layout_id", using: :btree

  create_table "gp_article_comments", force: :cascade do |t|
    t.integer  "doc_id",       limit: 4
    t.string   "state",        limit: 255
    t.string   "author_name",  limit: 255
    t.string   "author_email", limit: 255
    t.string   "author_url",   limit: 255
    t.string   "remote_addr",  limit: 255
    t.string   "user_agent",   limit: 255
    t.text     "body",         limit: 65535
    t.datetime "posted_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "gp_article_comments", ["doc_id"], name: "index_gp_article_comments_on_doc_id", using: :btree

  create_table "gp_article_docs", force: :cascade do |t|
    t.integer  "unid",                       limit: 4
    t.integer  "concept_id",                 limit: 4
    t.integer  "content_id",                 limit: 4
    t.string   "title",                      limit: 255
    t.text     "body",                       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "href",                       limit: 255
    t.string   "target",                     limit: 255
    t.text     "subtitle",                   limit: 65535
    t.text     "summary",                    limit: 65535
    t.string   "name",                       limit: 255
    t.datetime "published_at"
    t.datetime "recognized_at"
    t.string   "state",                      limit: 255
    t.string   "event_state",                limit: 255
    t.text     "raw_tags",                   limit: 65535
    t.string   "mobile_title",               limit: 255
    t.text     "mobile_body",                limit: 65535
    t.boolean  "terminal_pc_or_smart_phone"
    t.boolean  "terminal_mobile"
    t.string   "rel_doc_ids",                limit: 255
    t.datetime "display_published_at"
    t.datetime "display_updated_at"
    t.date     "event_started_on"
    t.date     "event_ended_on"
    t.string   "marker_state",               limit: 255
    t.text     "meta_description",           limit: 65535
    t.string   "meta_keywords",              limit: 255
    t.string   "list_image",                 limit: 255
    t.integer  "prev_edition_id",            limit: 4
    t.string   "og_type",                    limit: 255
    t.string   "og_title",                   limit: 255
    t.text     "og_description",             limit: 65535
    t.string   "og_image",                   limit: 255
    t.integer  "template_id",                limit: 4
    t.text     "template_values",            limit: 65535
    t.string   "share_to_sns_with",          limit: 255
    t.text     "body_more",                  limit: 65535
    t.string   "body_more_link_text",        limit: 255
    t.boolean  "feature_1"
    t.boolean  "feature_2"
    t.string   "filename_base",              limit: 255
    t.integer  "marker_icon_category_id",    limit: 4
    t.boolean  "keep_display_updated_at"
    t.integer  "layout_id",                  limit: 4
    t.text     "qrcode_state",               limit: 65535
    t.string   "event_will_sync",            limit: 255
  end

  add_index "gp_article_docs", ["concept_id"], name: "index_gp_article_docs_on_concept_id", using: :btree
  add_index "gp_article_docs", ["content_id"], name: "index_gp_article_docs_on_content_id", using: :btree
  add_index "gp_article_docs", ["event_started_on", "event_ended_on"], name: "index_gp_article_docs_on_event_started_on_and_event_ended_on", using: :btree
  add_index "gp_article_docs", ["event_state"], name: "index_gp_article_docs_on_event_state", using: :btree
  add_index "gp_article_docs", ["state"], name: "index_gp_article_docs_on_state", using: :btree
  add_index "gp_article_docs", ["terminal_pc_or_smart_phone"], name: "index_gp_article_docs_on_terminal_pc_or_smart_phone", using: :btree

  create_table "gp_article_docs_tag_tags", id: false, force: :cascade do |t|
    t.integer "doc_id", limit: 4
    t.integer "tag_id", limit: 4
  end

  create_table "gp_article_holds", force: :cascade do |t|
    t.integer  "holdable_id",   limit: 4
    t.string   "holdable_type", limit: 255
    t.integer  "user_id",       limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "gp_article_links", force: :cascade do |t|
    t.integer  "doc_id",     limit: 4
    t.string   "body",       limit: 255
    t.string   "url",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "gp_calendar_events", force: :cascade do |t|
    t.integer  "unid",                     limit: 4
    t.integer  "content_id",               limit: 4
    t.string   "state",                    limit: 255
    t.date     "started_on"
    t.date     "ended_on"
    t.string   "name",                     limit: 255
    t.string   "title",                    limit: 255
    t.string   "href",                     limit: 255
    t.string   "target",                   limit: 255
    t.text     "description",              limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "sync_source_host",         limit: 255
    t.integer  "sync_source_content_id",   limit: 4
    t.string   "sync_source_id",           limit: 255
    t.string   "sync_source_source_class", limit: 255
    t.string   "will_sync",                limit: 255
  end

  add_index "gp_calendar_events", ["content_id"], name: "index_gp_calendar_events_on_content_id", using: :btree
  add_index "gp_calendar_events", ["started_on", "ended_on"], name: "index_gp_calendar_events_on_started_on_and_ended_on", using: :btree
  add_index "gp_calendar_events", ["state"], name: "index_gp_calendar_events_on_state", using: :btree

  create_table "gp_calendar_events_gp_category_categories", id: false, force: :cascade do |t|
    t.integer "event_id",    limit: 4
    t.integer "category_id", limit: 4
  end

  create_table "gp_calendar_holidays", force: :cascade do |t|
    t.integer  "unid",                   limit: 4
    t.integer  "content_id",             limit: 4
    t.string   "state",                  limit: 255
    t.string   "title",                  limit: 255
    t.date     "date"
    t.text     "description",            limit: 65535
    t.string   "kind",                   limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "repeat"
    t.string   "sync_source_host",       limit: 255
    t.integer  "sync_source_content_id", limit: 4
    t.integer  "sync_source_id",         limit: 4
  end

  create_table "gp_category_categories", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "concept_id",       limit: 4
    t.integer  "layout_id",        limit: 4
    t.integer  "category_type_id", limit: 4
    t.integer  "parent_id",        limit: 4
    t.string   "state",            limit: 255
    t.string   "name",             limit: 255
    t.string   "title",            limit: 255
    t.integer  "level_no",         limit: 4
    t.integer  "sort_no",          limit: 4
    t.string   "description",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_code",       limit: 255
    t.string   "sitemap_state",    limit: 255
    t.string   "docs_order",       limit: 255
    t.integer  "template_id",      limit: 4
    t.integer  "children_count",   limit: 4,   default: 0, null: false
  end

  add_index "gp_category_categories", ["category_type_id"], name: "index_gp_category_categories_on_category_type_id", using: :btree
  add_index "gp_category_categories", ["concept_id"], name: "index_gp_category_categories_on_concept_id", using: :btree
  add_index "gp_category_categories", ["layout_id"], name: "index_gp_category_categories_on_layout_id", using: :btree
  add_index "gp_category_categories", ["parent_id"], name: "index_gp_category_categories_on_parent_id", using: :btree
  add_index "gp_category_categories", ["state"], name: "index_gp_category_categories_on_state", using: :btree

  create_table "gp_category_categorizations", force: :cascade do |t|
    t.integer  "categorizable_id",   limit: 4
    t.string   "categorizable_type", limit: 255
    t.integer  "category_id",        limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "sort_no",            limit: 4
    t.string   "categorized_as",     limit: 255
  end

  add_index "gp_category_categorizations", ["categorizable_id", "categorizable_type"], name: "index_gp_category_categorizations_on_categorizable_id_and_type", using: :btree
  add_index "gp_category_categorizations", ["categorized_as"], name: "index_gp_category_categorizations_on_categorized_as", using: :btree
  add_index "gp_category_categorizations", ["category_id"], name: "index_gp_category_categorizations_on_category_id", using: :btree

  create_table "gp_category_category_types", force: :cascade do |t|
    t.integer  "unid",                      limit: 4
    t.integer  "content_id",                limit: 4
    t.integer  "concept_id",                limit: 4
    t.integer  "layout_id",                 limit: 4
    t.string   "state",                     limit: 255
    t.string   "name",                      limit: 255
    t.string   "title",                     limit: 255
    t.integer  "sort_no",                   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sitemap_state",             limit: 255
    t.string   "docs_order",                limit: 255
    t.integer  "template_id",               limit: 4
    t.integer  "internal_category_type_id", limit: 4
  end

  add_index "gp_category_category_types", ["concept_id"], name: "index_gp_category_category_types_on_concept_id", using: :btree
  add_index "gp_category_category_types", ["content_id"], name: "index_gp_category_category_types_on_content_id", using: :btree
  add_index "gp_category_category_types", ["layout_id"], name: "index_gp_category_category_types_on_layout_id", using: :btree

  create_table "gp_category_publishers", force: :cascade do |t|
    t.integer  "category_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "gp_category_publishers", ["category_id"], name: "index_gp_category_publishers_on_category_id", using: :btree

  create_table "gp_category_template_modules", force: :cascade do |t|
    t.integer  "content_id",          limit: 4
    t.string   "name",                limit: 255
    t.string   "title",               limit: 255
    t.string   "module_type",         limit: 255
    t.string   "module_type_feature", limit: 255
    t.string   "wrapper_tag",         limit: 255
    t.text     "doc_style",           limit: 65535
    t.integer  "num_docs",            limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "upper_text",          limit: 65535
    t.text     "lower_text",          limit: 65535
  end

  add_index "gp_category_template_modules", ["content_id"], name: "index_gp_category_template_modules_on_content_id", using: :btree

  create_table "gp_category_templates", force: :cascade do |t|
    t.integer  "content_id", limit: 4
    t.string   "name",       limit: 255
    t.string   "title",      limit: 255
    t.text     "body",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "gp_category_templates", ["content_id"], name: "index_gp_category_templates_on_content_id", using: :btree

  create_table "gp_template_items", force: :cascade do |t|
    t.integer  "template_id",     limit: 4
    t.string   "state",           limit: 255
    t.string   "name",            limit: 255
    t.string   "title",           limit: 255
    t.string   "item_type",       limit: 255
    t.text     "item_options",    limit: 65535
    t.string   "style_attribute", limit: 255
    t.integer  "sort_no",         limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "gp_template_items", ["template_id"], name: "index_gp_template_items_on_template_id", using: :btree

  create_table "gp_template_templates", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.string   "state",      limit: 255
    t.string   "title",      limit: 255
    t.text     "body",       limit: 65535
    t.integer  "sort_no",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "gp_template_templates", ["content_id"], name: "index_gp_template_templates_on_content_id", using: :btree

  create_table "map_markers", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.string   "state",            limit: 255
    t.string   "title",            limit: 255
    t.string   "latitude",         limit: 255
    t.string   "longitude",        limit: 255
    t.text     "window_text",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",             limit: 255
    t.integer  "icon_category_id", limit: 4
  end

  create_table "organization_groups", force: :cascade do |t|
    t.integer  "unid",                limit: 4
    t.integer  "concept_id",          limit: 4
    t.integer  "layout_id",           limit: 4
    t.integer  "content_id",          limit: 4
    t.string   "state",               limit: 255
    t.string   "name",                limit: 255
    t.string   "sys_group_code",      limit: 255
    t.string   "sitemap_state",       limit: 255
    t.string   "docs_order",          limit: 255
    t.integer  "sort_no",             limit: 4
    t.text     "business_outline",    limit: 65535
    t.text     "contact_information", limit: 65535
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "more_layout_id",      limit: 4
    t.text     "outline",             limit: 65535
  end

  add_index "organization_groups", ["sys_group_code"], name: "index_organization_groups_on_sys_group_code", using: :btree

  create_table "rank_categories", force: :cascade do |t|
    t.integer  "content_id",  limit: 4
    t.string   "page_path",   limit: 255
    t.integer  "category_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "rank_ranks", force: :cascade do |t|
    t.integer  "content_id", limit: 4
    t.string   "page_title", limit: 255
    t.string   "hostname",   limit: 255
    t.string   "page_path",  limit: 255
    t.date     "date"
    t.integer  "pageviews",  limit: 4
    t.integer  "visitors",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "rank_totals", force: :cascade do |t|
    t.integer  "content_id", limit: 4
    t.string   "term",       limit: 255
    t.string   "page_title", limit: 255
    t.string   "hostname",   limit: 255
    t.string   "page_path",  limit: 255
    t.integer  "pageviews",  limit: 4
    t.integer  "visitors",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "sns_share_accounts", force: :cascade do |t|
    t.integer  "content_id",             limit: 4
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "info_nickname",          limit: 255
    t.string   "info_name",              limit: 255
    t.string   "info_image",             limit: 255
    t.string   "info_url",               limit: 255
    t.string   "credential_token",       limit: 255
    t.string   "credential_expires_at",  limit: 255
    t.string   "credential_secret",      limit: 255
    t.text     "facebook_page_options",  limit: 65535
    t.string   "facebook_page",          limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.text     "facebook_token_options", limit: 65535
    t.string   "facebook_token",         limit: 255
  end

  add_index "sns_share_accounts", ["content_id"], name: "index_sns_share_accounts_on_content_id", using: :btree

  create_table "sns_share_shares", force: :cascade do |t|
    t.integer  "sharable_id",   limit: 4
    t.string   "sharable_type", limit: 255
    t.integer  "account_id",    limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "sns_share_shares", ["sharable_type", "sharable_id"], name: "index_sns_share_shares_on_sharable_type_and_sharable_id", using: :btree

  create_table "survey_answers", force: :cascade do |t|
    t.integer  "form_answer_id", limit: 4
    t.integer  "question_id",    limit: 4
    t.text     "content",        limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "survey_answers", ["form_answer_id"], name: "index_survey_answers_on_form_answer_id", using: :btree
  add_index "survey_answers", ["question_id"], name: "index_survey_answers_on_question_id", using: :btree

  create_table "survey_form_answers", force: :cascade do |t|
    t.integer  "form_id",            limit: 4
    t.string   "answered_url",       limit: 255
    t.string   "remote_addr",        limit: 255
    t.string   "user_agent",         limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "answered_url_title", limit: 255
  end

  add_index "survey_form_answers", ["form_id"], name: "index_survey_form_answers_on_form_id", using: :btree

  create_table "survey_forms", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.integer  "content_id",    limit: 4
    t.string   "state",         limit: 255
    t.string   "name",          limit: 255
    t.string   "title",         limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.integer  "sort_no",       limit: 4
    t.text     "summary",       limit: 65535
    t.text     "description",   limit: 65535
    t.text     "receipt",       limit: 65535
    t.boolean  "confirmation"
    t.string   "sitemap_state", limit: 255
    t.string   "index_link",    limit: 255
  end

  add_index "survey_forms", ["content_id"], name: "index_survey_forms_on_content_id", using: :btree

  create_table "survey_questions", force: :cascade do |t|
    t.integer  "form_id",              limit: 4
    t.string   "state",                limit: 255
    t.string   "title",                limit: 255
    t.text     "description",          limit: 65535
    t.string   "form_type",            limit: 255
    t.text     "form_options",         limit: 65535
    t.boolean  "required"
    t.string   "style_attribute",      limit: 255
    t.integer  "sort_no",              limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "form_text_max_length", limit: 4
  end

  add_index "survey_questions", ["form_id"], name: "index_survey_questions_on_form_id", using: :btree

  create_table "sys_cache_sweepers", force: :cascade do |t|
    t.string   "state",      limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model",      limit: 255
    t.text     "uri",        limit: 65535
    t.text     "options",    limit: 65535
  end

  add_index "sys_cache_sweepers", ["model", "uri"], name: "model", length: {"model"=>20, "uri"=>30}, using: :btree

  create_table "sys_closers", force: :cascade do |t|
    t.integer  "unid",           limit: 4
    t.string   "dependent",      limit: 64
    t.string   "path",           limit: 255
    t.string   "content_hash",   limit: 255
    t.datetime "published_at"
    t.datetime "republished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sys_closers", ["unid", "dependent"], name: "index_sys_closers_on_unid_and_dependent", using: :btree

  create_table "sys_creators", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
  end

  create_table "sys_editable_groups", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "group_ids",  limit: 65535
    t.boolean  "all"
  end

  create_table "sys_editors", force: :cascade do |t|
    t.integer  "parent_unid", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     limit: 4
    t.integer  "group_id",    limit: 4
  end

  create_table "sys_files", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.string   "tmp_id",       limit: 255
    t.integer  "parent_unid",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",         limit: 255
    t.text     "title",        limit: 65535
    t.text     "mime_type",    limit: 65535
    t.integer  "size",         limit: 4
    t.integer  "image_is",     limit: 4
    t.integer  "image_width",  limit: 4
    t.integer  "image_height", limit: 4
  end

  add_index "sys_files", ["parent_unid", "name"], name: "parent_unid", using: :btree

  create_table "sys_groups", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.string   "state",        limit: 15
    t.string   "web_state",    limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",    limit: 4,   null: false
    t.integer  "level_no",     limit: 4
    t.string   "code",         limit: 255, null: false
    t.integer  "sort_no",      limit: 4
    t.integer  "layout_id",    limit: 4
    t.integer  "ldap",         limit: 4,   null: false
    t.string   "ldap_version", limit: 255
    t.string   "name",         limit: 255
    t.string   "name_en",      limit: 255
    t.string   "tel",          limit: 255
    t.string   "fax",          limit: 255
    t.string   "outline_uri",  limit: 255
    t.string   "email",        limit: 255
    t.string   "address",      limit: 255
    t.string   "note",         limit: 255
    t.string   "tel_attend",   limit: 255
  end

  add_index "sys_groups", ["code"], name: "index_sys_groups_on_code", using: :btree
  add_index "sys_groups", ["parent_id"], name: "index_sys_groups_on_parent_id", using: :btree
  add_index "sys_groups", ["state"], name: "index_sys_groups_on_state", using: :btree

  create_table "sys_languages", force: :cascade do |t|
    t.string   "state",      limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no",    limit: 4
    t.string   "name",       limit: 255
    t.text     "title",      limit: 65535
  end

  create_table "sys_ldap_synchros", force: :cascade do |t|
    t.integer  "parent_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version",    limit: 10
    t.string   "entry_type", limit: 15
    t.string   "code",       limit: 255
    t.integer  "sort_no",    limit: 4
    t.string   "name",       limit: 255
    t.string   "name_en",    limit: 255
    t.string   "email",      limit: 255
  end

  add_index "sys_ldap_synchros", ["version", "parent_id", "entry_type"], name: "version", using: :btree

  create_table "sys_maintenances", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.string   "state",        limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title",        limit: 65535
    t.text     "body",         limit: 65535
    t.integer  "site_id",      limit: 4
  end

  create_table "sys_messages", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.string   "state",        limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title",        limit: 65535
    t.text     "body",         limit: 65535
    t.integer  "site_id",      limit: 4
  end

  create_table "sys_object_privileges", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_unid",  limit: 4
    t.string   "action",     limit: 15
  end

  add_index "sys_object_privileges", ["item_unid", "action"], name: "item_unid", using: :btree

  create_table "sys_operation_logs", force: :cascade do |t|
    t.integer  "site_id",       limit: 4
    t.integer  "loggable_id",   limit: 4
    t.string   "loggable_type", limit: 255
    t.integer  "user_id",       limit: 4
    t.string   "operation",     limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "user_name",     limit: 255
    t.string   "ipaddr",        limit: 255
    t.string   "uri",           limit: 255
    t.string   "action",        limit: 255
    t.string   "item_model",    limit: 255
    t.integer  "item_id",       limit: 4
    t.integer  "item_unid",     limit: 4
    t.string   "item_name",     limit: 255
  end

  create_table "sys_processes", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "closed_at"
    t.integer  "user_id",    limit: 4
    t.string   "state",      limit: 255
    t.string   "name",       limit: 255
    t.string   "interrupt",  limit: 255
    t.integer  "total",      limit: 4
    t.integer  "current",    limit: 4
    t.integer  "success",    limit: 4
    t.integer  "error",      limit: 4
    t.text     "message",    limit: 4294967295
  end

  create_table "sys_publishers", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.string   "dependent",    limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path",         limit: 255
    t.string   "content_hash", limit: 255
  end

  add_index "sys_publishers", ["unid", "dependent"], name: "unid", using: :btree

  create_table "sys_recognitions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",        limit: 4
    t.string   "recognizer_ids", limit: 255
    t.text     "info_xml",       limit: 65535
  end

  add_index "sys_recognitions", ["user_id"], name: "user_id", using: :btree

  create_table "sys_role_names", force: :cascade do |t|
    t.integer  "site_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
    t.text     "title",      limit: 65535
  end

  create_table "sys_sequences", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
    t.integer  "version",    limit: 4
    t.integer  "value",      limit: 4
  end

  add_index "sys_sequences", ["name", "version"], name: "index_sys_sequences_on_name_and_version", unique: true, using: :btree

  create_table "sys_settings", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "value",       limit: 65535
    t.integer  "sort_no",     limit: 4
    t.text     "extra_value", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sys_tasks", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "process_at"
    t.string   "name",       limit: 255
  end

  create_table "sys_temp_texts", force: :cascade do |t|
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "sys_transferable_files", force: :cascade do |t|
    t.integer  "site_id",       limit: 4
    t.integer  "user_id",       limit: 4
    t.integer  "version",       limit: 4
    t.string   "operation",     limit: 255
    t.string   "file_type",     limit: 255
    t.string   "parent_dir",    limit: 255
    t.string   "path",          limit: 255
    t.string   "destination",   limit: 255
    t.integer  "operator_id",   limit: 4
    t.string   "operator_name", limit: 255
    t.datetime "operated_at"
    t.integer  "item_id",       limit: 4
    t.integer  "item_unid",     limit: 4
    t.string   "item_model",    limit: 255
    t.string   "item_name",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sys_transferable_files", ["user_id", "operator_id"], name: "index_sys_transferable_files_on_user_id_and_operator_id", using: :btree

  create_table "sys_transferred_files", force: :cascade do |t|
    t.integer  "site_id",       limit: 4
    t.integer  "version",       limit: 4
    t.string   "operation",     limit: 255
    t.string   "file_type",     limit: 255
    t.string   "parent_dir",    limit: 255
    t.string   "path",          limit: 255
    t.string   "destination",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",       limit: 4
    t.integer  "operator_id",   limit: 4
    t.string   "operator_name", limit: 255
    t.datetime "operated_at"
    t.integer  "item_id",       limit: 4
    t.integer  "item_unid",     limit: 4
    t.string   "item_model",    limit: 255
    t.string   "item_name",     limit: 255
  end

  add_index "sys_transferred_files", ["created_at"], name: "index_sys_transferred_files_on_created_at", using: :btree
  add_index "sys_transferred_files", ["operator_id"], name: "index_sys_transferred_files_on_operator_id", using: :btree
  add_index "sys_transferred_files", ["user_id"], name: "index_sys_transferred_files_on_user_id", using: :btree
  add_index "sys_transferred_files", ["version"], name: "index_sys_transferred_files_on_version", using: :btree

  create_table "sys_unid_relations", force: :cascade do |t|
    t.integer "unid",     limit: 4,   null: false
    t.integer "rel_unid", limit: 4,   null: false
    t.string  "rel_type", limit: 255, null: false
  end

  add_index "sys_unid_relations", ["rel_unid"], name: "rel_unid", using: :btree
  add_index "sys_unid_relations", ["unid"], name: "unid", using: :btree

  create_table "sys_unids", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model",      limit: 255, null: false
    t.integer  "item_id",    limit: 4
  end

  create_table "sys_users", force: :cascade do |t|
    t.string   "state",                           limit: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ldap",                            limit: 4,                     null: false
    t.string   "ldap_version",                    limit: 255
    t.integer  "auth_no",                         limit: 4,                     null: false
    t.string   "name",                            limit: 255
    t.string   "name_en",                         limit: 255
    t.string   "account",                         limit: 255
    t.string   "password",                        limit: 255
    t.string   "email",                           limit: 255
    t.text     "remember_token",                  limit: 65535
    t.datetime "remember_token_expires_at"
    t.boolean  "admin_creatable",                               default: false
    t.boolean  "site_creatable",                                default: false
    t.string   "reset_password_token",            limit: 255
    t.datetime "reset_password_token_expires_at"
  end

  create_table "sys_users_groups", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
  end

  add_index "sys_users_groups", ["user_id", "group_id"], name: "user_id", using: :btree

  create_table "sys_users_roles", force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "sys_users_roles", ["user_id", "role_id"], name: "user_id", using: :btree

  create_table "tag_tags", force: :cascade do |t|
    t.integer  "content_id",     limit: 4
    t.text     "word",           limit: 65535
    t.datetime "last_tagged_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_tags", ["content_id"], name: "index_tag_tags_on_content_id", using: :btree

  create_table "tool_convert_docs", force: :cascade do |t|
    t.integer  "content_id",      limit: 4
    t.integer  "docable_id",      limit: 4
    t.string   "docable_type",    limit: 255
    t.text     "doc_name",        limit: 65535
    t.text     "doc_public_uri",  limit: 65535
    t.text     "site_url",        limit: 65535
    t.string   "file_path",       limit: 255
    t.text     "uri_path",        limit: 65535
    t.text     "title",           limit: 65535
    t.text     "body",            limit: 4294967295
    t.string   "page_updated_at", limit: 255
    t.string   "page_group_code", limit: 255
    t.datetime "published_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "tool_convert_docs", ["content_id"], name: "index_tool_convert_docs_on_content_id", using: :btree
  add_index "tool_convert_docs", ["docable_id", "docable_type"], name: "index_tool_convert_docs_on_docable_id_and_docable_type", using: :btree
  add_index "tool_convert_docs", ["uri_path"], name: "index_tool_convert_docs_on_uri_path", length: {"uri_path"=>255}, using: :btree

  create_table "tool_convert_downloads", force: :cascade do |t|
    t.string   "state",           limit: 255
    t.text     "site_url",        limit: 65535
    t.text     "include_dir",     limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "recursive_level", limit: 4
    t.string   "remark",          limit: 255
    t.text     "message",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tool_convert_imports", force: :cascade do |t|
    t.string   "state",              limit: 255
    t.text     "site_url",           limit: 65535
    t.string   "site_filename",      limit: 255
    t.integer  "content_id",         limit: 4
    t.integer  "overwrite",          limit: 4
    t.integer  "keep_filename",      limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "message",            limit: 65535
    t.integer  "total_num",          limit: 4
    t.integer  "created_num",        limit: 4
    t.integer  "updated_num",        limit: 4
    t.integer  "nonupdated_num",     limit: 4
    t.integer  "skipped_num",        limit: 4
    t.integer  "link_total_num",     limit: 4
    t.integer  "link_processed_num", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tool_convert_links", force: :cascade do |t|
    t.integer  "concept_id",    limit: 4
    t.integer  "linkable_id",   limit: 4
    t.string   "linkable_type", limit: 255
    t.text     "urls",          limit: 65535
    t.text     "before_body",   limit: 4294967295
    t.text     "after_body",    limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tool_convert_settings", force: :cascade do |t|
    t.string   "site_url",                      limit: 255
    t.text     "title_tag",                     limit: 65535
    t.text     "body_tag",                      limit: 65535
    t.text     "updated_at_tag",                limit: 65535
    t.text     "updated_at_regexp",             limit: 65535
    t.text     "creator_group_from_url_regexp", limit: 65535
    t.integer  "creator_group_relation_type",   limit: 4
    t.text     "creator_group_url_relations",   limit: 65535
    t.text     "category_tag",                  limit: 65535
    t.text     "category_regexp",               limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "tool_convert_settings", ["site_url"], name: "index_tool_convert_settings_on_site_url", using: :btree

  create_table "tool_simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
