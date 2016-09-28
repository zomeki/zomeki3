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
end
