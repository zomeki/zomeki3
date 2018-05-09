Cms::Lib::Modules::ModuleSet.draw :cms, '標準機能', 1 do |mod|
  ## contents
  ;
  
  ## directory
  mod.directory :directories, 'ディレクトリ'
  
  ## pages
  mod.page :pages, '自由形式'
  mod.page :sitemaps, 'サイトマップ'
  
  ## pieces
  mod.piece :frees, '自由形式'
  mod.piece :page_titles, 'ページタイトル'
  mod.piece :bread_crumbs, 'パンくず'
  mod.piece :links, 'リンク集'
  mod.piece :sns_parts, 'SNSパーツ'
  mod.piece :pickup_docs, 'ピックアップ記事'

  ## public models
  mod.public_model :brackets
  mod.public_model :concepts
  mod.public_model :content_settings
  mod.public_model :contents
  mod.public_model :data_file_nodes
  mod.public_model :data_files
  mod.public_model :data_texts
  mod.public_model :inquiries
  mod.public_model :kana_dictionaries
  mod.public_model :layouts
  mod.public_model :links
  mod.public_model :map_markers
  mod.public_model :maps
  mod.public_model :nodes
  mod.public_model :piece_link_items
  mod.public_model :piece_settings
  mod.public_model :pieces
  mod.public_model :publish_urls
  mod.public_model :site_belongings
  mod.public_model :site_settings
  mod.public_model :sites
  mod.public_model :stylesheets
end
