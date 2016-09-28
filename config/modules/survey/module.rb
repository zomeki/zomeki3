Cms::Lib::Modules::ModuleSet.draw :survey, '問合せ', 110 do |mod|
  ## contents
  mod.content :forms, '問合せ'

  ## directories
  mod.directory :forms, 'フォーム一覧'

  ## pieces
  mod.piece :forms, 'フォーム'
end
