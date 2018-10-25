class CreateCmsLinkChecks < ActiveRecord::Migration[4.2]
  def change
    create_table :cms_link_checks do |t|
      t.boolean :in_progress
      t.boolean :checked

      t.timestamps
    end
  end
end
