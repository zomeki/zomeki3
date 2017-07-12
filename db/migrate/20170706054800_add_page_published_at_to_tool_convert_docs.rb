class AddPagePublishedAtToToolConvertDocs < ActiveRecord::Migration[5.0]
  def change
    add_column :tool_convert_docs, :page_published_at, :string
    add_column :tool_convert_docs, :page_category_names, :text
  end
end
