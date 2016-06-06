class AddSiteIdToCmsKanaDictionaries < ActiveRecord::Migration
  def change
    add_column :cms_kana_dictionaries, :site_id, :integer, :after => :unid
    site = Cms::Site.where(state: 'public').order(:id).first
    Cms::KanaDictionary.update_all(site_id: site.id) if site
  end
end
