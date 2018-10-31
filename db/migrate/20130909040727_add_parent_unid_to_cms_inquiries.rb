class AddParentUnidToCmsInquiries < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_inquiries, :parent_unid, :integer, :after => :id
    add_index :cms_inquiries, :parent_unid
    
    Cms::Inquiry.update_all("parent_unid = id")
  end
end
