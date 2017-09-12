class AddCreatedAtAndUpdatedAtToSomeTables < ActiveRecord::Migration[5.0]
  def change
    [:gnav_category_sets,
     :gp_article_docs_tag_tags,
     :sys_users_roles,
     :sys_object_relations].each do |table|
      add_column table, :created_at, :datetime
      add_column table, :updated_at, :datetime
    end
  end
end
