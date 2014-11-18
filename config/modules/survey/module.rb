# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :survey, 'アンケート' do |mod|
  ## contents
  mod.content :forms, 'アンケート'

  ## directories
  mod.directory :forms, 'フォーム一覧'

  ## pieces
  mod.piece :forms, 'フォーム'
end
