Cms::Lib::Modules::ModuleSet.draw :gp_article, '記事', 10 do |mod|
  ## contents
  mod.content :docs, '記事'

  ## directories
  mod.directory :docs, '記事ページ'
  mod.directory :archives, 'アーカイブ一覧'
  mod.directory :search_docs, '検索結果一覧'

  ## pieces
  mod.piece :docs, '記事一覧'
  mod.piece :recent_tabs, '新着タブ'
  mod.piece :archives, 'アーカイブ'
  mod.piece :comments, '最新コメント'
  mod.piece :search_docs, '検索フォーム'
end
