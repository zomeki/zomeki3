Cms::Lib::Modules::ModuleSet.draw :sys, 'システム', 0 do |mod|
  ## public models
  mod.public_model :creators
  mod.public_model :editors
  mod.public_model :files
  mod.public_model :groups
  mod.public_model :settings
  mod.public_model :storage_files
end
