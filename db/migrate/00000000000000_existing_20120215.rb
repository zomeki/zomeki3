class Existing20120215 < ActiveRecord::Migration
  def change
    create_table "article_areas", :force => true do |t|
      t.integer  "unid"
      t.integer  "parent_id",                :null => false
      t.integer  "concept_id"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",                 :null => false
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.string   "name"
      t.text     "title"
      t.text     "zip_code"
      t.text     "address"
      t.text     "tel"
      t.text     "site_uri"
    end

    create_table "article_attributes", :force => true do |t|
      t.integer  "unid"
      t.integer  "concept_id"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.string   "name"
      t.text     "title"
    end

    create_table "article_categories", :force => true do |t|
      t.integer  "unid"
      t.integer  "parent_id",                :null => false
      t.integer  "concept_id"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",                 :null => false
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.string   "name"
      t.text     "title"
    end

    create_table "article_docs", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.string   "state"
      t.string   "agent_state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "recognized_at"
      t.datetime "published_at"
      t.integer  "language_id"
      t.string   "category_ids"
      t.string   "attribute_ids"
      t.string   "area_ids"
      t.string   "rel_doc_ids"
      t.text     "notice_state"
      t.text     "recent_state"
      t.text     "list_state"
      t.text     "event_state"
      t.date     "event_date"
      t.string   "name"
      t.text     "title"
      t.text     "head"
      t.text     "body"
      t.text     "mobile_title"
      t.text     "mobile_body"
    end

    add_index "article_docs", ["content_id", "published_at", "event_date"], name: 'idx_article_docs_on_c_id_and_p_at_and_e_date'

    create_table "article_tags", :force => true do |t|
      t.integer  "unid"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "word"
    end

    create_table "bbs_items", :force => true do |t|
      t.integer  "parent_id"
      t.integer  "thread_id"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.string   "email"
      t.string   "uri"
      t.text     "title"
      t.text     "body"
      t.string   "password"
      t.string   "ipaddr"
      t.string   "user_agent"
    end

    create_table "calendar_events", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.date     "event_date"
      t.string   "event_uri"
      t.text     "title"
      t.text     "body"
    end

    add_index "calendar_events", ["content_id", "published_at", "event_date"], name: 'idx_calendar_events_on_c_id_and_p_at_and_e_date'

    create_table "cms_concepts", :force => true do |t|
      t.integer  "unid"
      t.integer  "parent_id"
      t.integer  "site_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",                 :null => false
      t.integer  "sort_no"
      t.string   "name"
    end

    add_index "cms_concepts", ["parent_id", "state", "sort_no"]

    create_table "cms_content_settings", :force => true do |t|
      t.integer  "content_id", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "value"
      t.integer  "sort_no"
    end

    add_index "cms_content_settings", ["content_id"]

    create_table "cms_contents", :force => true do |t|
      t.integer  "unid"
      t.integer  "site_id",                              :null => false
      t.integer  "concept_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "model"
      t.string   "name"
      t.text     "xml_properties"
    end

    create_table "cms_data_file_nodes", :force => true do |t|
      t.integer  "unid"
      t.integer  "site_id"
      t.integer  "concept_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "title"
    end

    add_index "cms_data_file_nodes", ["concept_id", "name"]

    create_table "cms_data_files", :force => true do |t|
      t.integer  "unid"
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
    end

    add_index "cms_data_files", ["concept_id", "node_id", "name"]

    create_table "cms_data_texts", :force => true do |t|
      t.integer  "unid"
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

    create_table "cms_feed_entries", :force => true do |t|
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
    end

    add_index "cms_feed_entries", ["feed_id", "content_id", "entry_updated"], name: 'idx_cms_feed_entries_on_f_id_and_c_id_and_e_updated'

    create_table "cms_feeds", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.text     "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",           :null => false
      t.text     "uri"
      t.text     "title"
      t.string   "feed_id"
      t.string   "feed_type"
      t.datetime "feed_updated"
      t.text     "feed_title"
      t.text     "link_alternate"
      t.integer  "entry_count"
    end

    create_table "cms_inquiries", :force => true do |t|
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.integer  "group_id"
      t.text     "charge"
      t.text     "tel"
      t.text     "fax"
      t.text     "email"
    end

    create_table "cms_kana_dictionaries", :force => true do |t|
      t.integer  "unid"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "body"
      t.text     "ipadic_body"
      t.text     "unidic_body"
    end

    create_table "cms_layouts", :force => true do |t|
      t.integer  "unid"
      t.integer  "concept_id"
      t.integer  "template_id"
      t.integer  "site_id",                                      :null => false
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

    create_table "cms_map_markers", :force => true do |t|
      t.integer  "map_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no"
      t.string   "name"
      t.string   "lat"
      t.string   "lng"
    end

    add_index "cms_map_markers", ["map_id"]

    create_table "cms_maps", :force => true do |t|
      t.integer  "unid"
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
    end

    create_table "cms_nodes", :force => true do |t|
      t.integer  "unid"
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
    end

    add_index "cms_nodes", ["parent_id", "name"]

    create_table "cms_piece_link_items", :force => true do |t|
      t.integer  "piece_id",                 :null => false
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "body"
      t.string   "uri"
      t.integer  "sort_no"
      t.string   "target"
    end

    add_index "cms_piece_link_items", ["piece_id"]

    create_table "cms_piece_settings", :force => true do |t|
      t.integer  "piece_id",   :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "value"
      t.integer  "sort_no"
    end

    add_index "cms_piece_settings", ["piece_id"]

    create_table "cms_pieces", :force => true do |t|
      t.integer  "unid"
      t.integer  "concept_id"
      t.integer  "site_id",                              :null => false
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
    end

    add_index "cms_pieces", ["concept_id", "name", "state"]

    create_table "cms_site_settings", :force => true do |t|
      t.integer  "site_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "value"
      t.integer  "sort_no"
    end

    add_index "cms_site_settings", ["site_id", "name"]

    create_table "cms_sites", :force => true do |t|
      t.integer  "unid"
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
    end

    create_table "cms_talk_tasks", :force => true do |t|
      t.integer  "unid"
      t.string   "dependent"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "path"
      t.string   "content_hash"
    end

    add_index "cms_talk_tasks", ["unid", "dependent"]

    create_table "enquete_answer_columns", :force => true do |t|
      t.integer "answer_id"
      t.integer "form_id"
      t.integer "column_id"
      t.text    "value"
    end

    add_index "enquete_answer_columns", ["answer_id", "form_id", "column_id"], name: 'idx_enquete_answer_columns_on_a_id_and_f_id_and_c_id'

    create_table "enquete_answers", :force => true do |t|
      t.integer  "content_id"
      t.integer  "form_id"
      t.string   "state"
      t.datetime "created_at"
      t.string   "ipaddr"
      t.text     "user_agent"
    end

    add_index "enquete_answers", ["content_id", "form_id"]

    create_table "enquete_form_columns", :force => true do |t|
      t.integer  "unid"
      t.integer  "form_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no"
      t.text     "name"
      t.text     "body"
      t.string   "column_type"
      t.string   "column_style"
      t.integer  "required"
      t.text     "options"
    end

    add_index "enquete_form_columns", ["form_id", "sort_no"]

    create_table "enquete_forms", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no"
      t.text     "name"
      t.text     "body"
      t.text     "summary"
      t.text     "sent_body"
    end

    add_index "enquete_forms", ["content_id", "sort_no"]

    create_table "laby_docs", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.string   "name"
      t.text     "title"
      t.text     "head"
      t.text     "body"
    end

    create_table "newsletter_delivery_logs", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "doc_id"
      t.string   "letter_type"
      t.text     "title"
      t.text     "body"
      t.string   "delivery_state"
      t.integer  "delivered_count"
      t.integer  "deliverable_count"
      t.integer  "last_member_id"
    end

    add_index "newsletter_delivery_logs", ["content_id", "doc_id", "letter_type"], name: 'idx_newsletter_delivery_logs_on_c_id_and_d_id_and_l_type'

    create_table "newsletter_docs", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "delivery_state"
      t.datetime "delivered_at"
      t.string   "name"
      t.text     "title"
      t.text     "body"
      t.text     "mobile_title"
      t.text     "mobile_body"
    end

    add_index "newsletter_docs", ["content_id", "updated_at"]

    create_table "newsletter_members", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "letter_type"
      t.text     "email"
      t.integer  "delivered_doc_id"
      t.datetime "delivered_at"
    end

    add_index "newsletter_members", ["content_id", "letter_type", "created_at"], name: 'idx_newsletter_members_on_c_id_and_l_type_and_c_at'

    create_table "newsletter_requests", :force => true do |t|
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "request_state"
      t.string   "request_type"
      t.string   "letter_type"
      t.text     "subscribe_email"
      t.text     "unsubscribe_email"
      t.text     "token"
    end

    add_index "newsletter_requests", ["content_id", "request_state", "request_type"], name: 'idx_newsletter_requests_on_c_id_and_r_state_and_r_type'

    create_table "newsletter_tests", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.string   "state"
      t.string   "agent_state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "name"
      t.text     "email"
    end

    create_table "portal_article_categories", :force => true do |t|
      t.integer  "unid"
      t.integer  "parent_id",                :null => false
      t.integer  "concept_id"
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",                 :null => false
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.string   "name"
      t.text     "title"
    end

    create_table "portal_article_docs", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.string   "state"
      t.string   "agent_state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "recognized_at"
      t.datetime "published_at"
      t.integer  "language_id"
      t.text     "category_ids"
      t.integer  "portal_group_id"
      t.text     "portal_category_ids"
      t.text     "portal_business_ids"
      t.text     "portal_attribute_ids"
      t.text     "portal_area_ids"
      t.string   "rel_doc_ids"
      t.text     "notice_state"
      t.string   "name"
      t.text     "title"
      t.text     "head"
      t.text     "body"
      t.text     "mobile_title"
      t.text     "mobile_body"
    end

    create_table "portal_article_tags", :force => true do |t|
      t.integer  "unid"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "word"
    end

    create_table "portal_categories", :force => true do |t|
      t.integer  "unid"
      t.integer  "parent_id",                              :null => false
      t.integer  "content_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",                               :null => false
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.string   "name"
      t.text     "title"
      t.text     "entry_categories"
    end

    add_index "portal_categories", ["parent_id", "content_id", "state"]

    create_table "portal_group_areas", :force => true do |t|
      t.integer  "unid"
      t.integer  "parent_id",                :null => false
      t.integer  "content_id"
      t.integer  "concept_id"
      t.integer  "site_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",                 :null => false
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.string   "name"
      t.text     "title"
      t.text     "zip_code"
      t.text     "address"
      t.text     "tel"
      t.text     "site_uri"
    end

    create_table "portal_group_attributes", :force => true do |t|
      t.integer  "unid"
      t.integer  "content_id"
      t.integer  "concept_id"
      t.integer  "site_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.string   "name"
      t.text     "title"
    end

    create_table "portal_group_businesses", :force => true do |t|
      t.integer  "unid"
      t.integer  "parent_id",                :null => false
      t.integer  "content_id"
      t.integer  "concept_id"
      t.integer  "site_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",                 :null => false
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.string   "name"
      t.text     "title"
    end

    create_table "portal_group_categories", :force => true do |t|
      t.integer  "unid"
      t.integer  "parent_id",                :null => false
      t.integer  "content_id"
      t.integer  "concept_id"
      t.integer  "site_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",                 :null => false
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.string   "name"
      t.text     "title"
    end

    create_table "sys_creators", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.integer  "group_id"
    end

    create_table "sys_editable_groups", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "group_ids"
    end

    create_table "sys_files", :force => true do |t|
      t.integer  "unid"
      t.string   "tmp_id"
      t.integer  "parent_unid"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "title"
      t.text     "mime_type"
      t.integer  "size"
      t.integer  "image_is"
      t.integer  "image_width"
      t.integer  "image_height"
    end

    add_index "sys_files", ["parent_unid", "name"]

    create_table "sys_groups", :force => true do |t|
      t.integer  "unid"
      t.string   "state"
      t.string   "web_state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "parent_id",                  :null => false
      t.integer  "level_no"
      t.string   "code",                       :null => false
      t.integer  "sort_no"
      t.integer  "layout_id"
      t.integer  "ldap",                       :null => false
      t.string   "ldap_version"
      t.string   "name"
      t.string   "name_en"
      t.string   "tel"
      t.string   "outline_uri"
      t.string   "email"
    end

    create_table "sys_languages", :force => true do |t|
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no"
      t.string   "name"
      t.text     "title"
    end

    create_table "sys_ldap_synchros", :force => true do |t|
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
    end

    add_index "sys_ldap_synchros", ["version", "parent_id", "entry_type"]

    create_table "sys_maintenances", :force => true do |t|
      t.integer  "unid"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.text     "title"
      t.text     "body"
    end

    create_table "sys_messages", :force => true do |t|
      t.integer  "unid"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.text     "title"
      t.text     "body"
    end

    create_table "sys_object_privileges", :force => true do |t|
      t.integer  "role_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "item_unid"
      t.string   "action"
    end

    add_index "sys_object_privileges", ["item_unid", "action"]

    create_table "sys_publishers", :force => true do |t|
      t.integer  "unid"
      t.string   "dependent"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "path"
      t.string   "content_hash"
    end

    add_index "sys_publishers", ["unid", "dependent"]

    create_table "sys_recognitions", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.string   "recognizer_ids"
      t.text     "info_xml"
    end

    add_index "sys_recognitions", ["user_id"]

    create_table "sys_role_names", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.text     "title"
    end

    create_table "sys_sequences", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.integer  "version"
      t.integer  "value"
    end

    add_index "sys_sequences", ["name", "version"]

    create_table "sys_tasks", :force => true do |t|
      t.integer  "unid"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "process_at"
      t.string   "name"
    end

    create_table "sys_unid_relations", :force => true do |t|
      t.integer "unid",     :null => false
      t.integer "rel_unid", :null => false
      t.string  "rel_type", :null => false
    end

    add_index "sys_unid_relations", ["rel_unid"]
    add_index "sys_unid_relations", ["unid"]

    create_table "sys_unids", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "model",      :null => false
      t.integer  "item_id"
    end

    create_table "sys_users", :force => true do |t|
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "ldap",                                    :null => false
      t.string   "ldap_version"
      t.integer  "auth_no",                                 :null => false
      t.string   "name"
      t.string   "name_en"
      t.string   "account"
      t.string   "password"
      t.string   "email"
      t.text     "remember_token"
      t.datetime "remember_token_expires_at"
    end

    create_table "sys_users_groups", :id => false, :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.integer  "group_id"
    end

    add_index "sys_users_groups", ["user_id", "group_id"]

    create_table "sys_users_roles", :force => true do |t|
      t.integer "user_id"
      t.integer "role_id"
    end

    add_index "sys_users_roles", ["user_id", "role_id"]

    create_table "tool_simple_captcha_data", :force => true do |t|
      t.string   "key"
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
