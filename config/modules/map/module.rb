Cms::Lib::Modules::ModuleSet.draw :map, '地図', 30 do |mod|
  ## contents
  mod.content :markers, '地図'

  ## directories
  mod.directory :markers, 'マップ'
  mod.directory :navigations, '周辺検索'

  ## pieces
  mod.piece :category_types, 'カテゴリ一覧'
end
