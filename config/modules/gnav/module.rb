Cms::Lib::Modules::ModuleSet.draw :gnav, 'グローバルナビ', 100 do |mod|
  ## contents
  mod.content :menu_items, 'グローバルナビ', publishable: true

  ## directories
  mod.directory :menu_items, 'グローバルナビ'

  ## pieces
  mod.piece :category_types, 'カテゴリ一覧'
  mod.piece :docs, '記事一覧'

  ## public models
  mod.public_model :menu_items
  mod.public_model :category_sets
end
