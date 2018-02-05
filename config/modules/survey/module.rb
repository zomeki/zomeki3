Cms::Lib::Modules::ModuleSet.draw :survey, '問合せ', 110 do |mod|
  ## contents
  mod.content :forms, '問合せ', publishable: true

  ## directories
  mod.directory :forms, 'フォーム一覧', dynamic: true

  ## pieces
  mod.piece :forms, 'フォーム'
end
