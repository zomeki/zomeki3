Cms::Lib::Modules::ModuleSet.draw :reception, '講座', 150 do |mod|
  ## contents
  mod.content :courses, '講座'

  ## directories
  mod.directory :courses, '講座一覧'

  ## pieces
  mod.piece :courses, '講座一覧'
end
