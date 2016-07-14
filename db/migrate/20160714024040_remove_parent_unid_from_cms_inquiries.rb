class RemoveParentUnidFromCmsInquiries < ActiveRecord::Migration
  def change
    remove_column :cms_inquiries, :parent_unid, :integer
  end
end
