class CreateFeedFeeds < ActiveRecord::Migration
  def change
    create_table :feed_feeds do |t|
      t.integer  :unid
      t.integer  :content_id
      t.text     :state
      t.timestamps
      t.string   :name,                 :null => false
      t.text     :uri
      t.text     :title
      t.string   :feed_id
      t.string   :feed_type
      t.datetime :feed_updated
      t.text     :feed_title
      t.text     :link_alternate
      t.integer  :entry_count
      t.text     :fixed_categories_xml
    end
    
    create_table :feed_feed_entries, :force => true do |t|
      t.integer  :feed_id
      t.integer  :content_id
      t.text     :state
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :entry_id
      t.datetime :entry_updated
      t.date     :event_date
      t.text     :title
      t.text     :summary
      t.text     :link_alternate
      t.text     :link_enclosure
      t.text     :categories
      t.text     :categories_xml
      t.text     :image_uri
      t.integer  :image_length
      t.text     :image_type
      t.text     :author_name
      t.string   :author_email
      t.text     :author_uri
    end
      
  end
end
