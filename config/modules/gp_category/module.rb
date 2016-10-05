Cms::Lib::Modules::ModuleSet.draw :gp_category, 'カテゴリ', 20 do |mod|
  ## contents
  mod.content :category_types, 'カテゴリ'

  ## directories
  mod.directory :category_types, 'カテゴリ種別ページ'
  mod.directory :docs, '新着記事一覧ページ'

  ## pieces
  mod.piece :category_types, 'カテゴリ別記事一覧'
  mod.piece :category_lists, 'カテゴリ一覧'
  mod.piece :categories, 'ブログカテゴリ一覧'
  mod.piece :docs, '記事一覧'
  mod.piece :recent_tabs, '新着タブ'
  mod.piece :feeds, 'フィード'
  mod.piece :category_summaries, 'カテゴリ説明'
end
