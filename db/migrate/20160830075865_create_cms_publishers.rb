class CreateCmsPublishers < ActiveRecord::Migration
  def change
    create_table :cms_publishers do |t|
      t.references :site, index: true
      t.references :publishable, index: true, polymorphic: true
      t.string     :state
      t.integer    :priority
      t.jsonb      :extra_flag, default: '{}'
      t.timestamps
    end
  end
end
