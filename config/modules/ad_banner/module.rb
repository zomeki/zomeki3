Cms::Lib::Modules::ModuleSet.draw :ad_banner, '広告バナー', 90 do |mod|
  ## contents
  mod.content :banners, '広告バナー', publishable: true

  ## directories
  mod.directory :banners, '広告バナー'

  ## pieces
  mod.piece :banners, '広告バナー一覧'

  ## public models
  mod.public_model :banners
  mod.public_model :groups
end
