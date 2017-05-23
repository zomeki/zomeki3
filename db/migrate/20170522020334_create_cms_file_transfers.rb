class CreateCmsFileTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :cms_file_transfers do |t|
      t.references :site, index: true
      t.string     :state
      t.string     :path
      t.boolean    :recursive
      t.integer    :priority
      t.timestamps
    end
  end
end
