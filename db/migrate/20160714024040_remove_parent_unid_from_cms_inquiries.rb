class RemoveParentUnidFromCmsInquiries < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_inquiries, :parent_unid, :integer
  end
end
