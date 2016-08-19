Cms::Lib::Modules::ModuleSet.draw :gnav, 'グローバルナビ' do |mod|
  ## contents
  mod.content :menu_items, 'グローバルナビ'

  ## directories
  mod.directory :menu_items, 'グローバルナビ'

  ## pieces
  mod.piece :category_types, 'カテゴリ一覧'
  mod.piece :docs, '記事一覧'
end
