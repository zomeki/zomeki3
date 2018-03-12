Cms::Lib::Modules::ModuleSet.draw :gp_article, '記事', 10 do |mod|
  ## contents
  mod.content :docs, '記事', publishable: true

  ## directories
  mod.directory :docs, '記事ページ'
  mod.directory :archives, 'アーカイブ一覧'
  mod.directory :search_docs, '検索結果一覧', dynamic: true

  ## pieces
  mod.piece :docs, '記事一覧'
  mod.piece :recent_tabs, '新着タブ'
  mod.piece :archives, 'アーカイブ'
  mod.piece :search_docs, '検索フォーム'

  ## public models
  mod.public_model :docs
  mod.public_model :docs_tag_tags
  mod.public_model :related_docs
end
