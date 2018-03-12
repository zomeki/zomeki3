Cms::Lib::Modules::ModuleSet.draw :gp_template, 'テンプレート', 130 do |mod|
  ## contents
  mod.content :templates, 'テンプレート'

  # models
  mod.public_model :items
  mod.public_model :templates
end
