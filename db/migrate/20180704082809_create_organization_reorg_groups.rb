class CreateOrganizationReorgGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :organization_reorg_groups do |t|
      t.references :concept
      t.references :layout
      t.references :content
      t.string     :state
      t.string     :name
      t.string     :sys_group_code
      t.string     :sitemap_state
      t.string     :docs_order
      t.integer    :sort_no
      t.text       :business_outline
      t.text       :contact_information
      t.timestamps
      t.references :more_layout
      t.text       :outline
      t.string     :title
      t.string     :change_state
    end
  end
end
