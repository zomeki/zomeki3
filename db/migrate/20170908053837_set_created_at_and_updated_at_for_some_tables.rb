class SetCreatedAtAndUpdatedAtForSomeTables < ActiveRecord::Migration[5.0]
  def up
    [:created_at, :updated_at].each do |column|
      execute "update gnav_category_sets set #{column} = gnav_menu_items.#{column} from gnav_menu_items where gnav_menu_items.id = gnav_category_sets.menu_item_id"
      execute "update gp_article_docs_tag_tags set #{column} = gp_article_docs.#{column} from gp_article_docs where gp_article_docs.id = gp_article_docs_tag_tags.doc_id"
      execute "update sys_users_roles set #{column} = sys_users.#{column} from sys_users where sys_users.id = sys_users_roles.user_id"
      execute "update sys_object_relations set #{column} = cms_nodes.#{column} from cms_nodes where cms_nodes.id = sys_object_relations.source_id and sys_object_relations.source_type = 'Cms::Node'"
      execute "update sys_object_relations set #{column} = cms_pieces.#{column} from cms_pieces where cms_pieces.id = sys_object_relations.source_id and sys_object_relations.source_type = 'Cms::Piece'"
    end
  end

  def down
  end
end
