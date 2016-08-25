class CreateOrganizationPublishers < ActiveRecord::Migration
  def change
    create_table :organization_publishers do |t|
      t.integer :organization_group_id, index: true
      t.timestamps
    end
  end
end
