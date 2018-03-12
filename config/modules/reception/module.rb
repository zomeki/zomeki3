Cms::Lib::Modules::ModuleSet.draw :reception, '講座', 150 do |mod|
  ## contents
  mod.content :courses, '講座'

  ## directories
  mod.directory :courses, '講座一覧', dynamic: true

  ## pieces
  mod.piece :courses, '講座一覧'

  ## public models
  mod.public_model :courses
  mod.public_model :opens
  mod.public_model :applicant_tokens
end
