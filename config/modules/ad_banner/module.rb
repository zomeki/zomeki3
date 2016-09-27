Cms::Lib::Modules::ModuleSet.draw :ad_banner, '広告バナー', 90 do |mod|
  ## contents
  mod.content :banners, '広告バナー'

  ## directories
  mod.directory :banners, '広告バナー'

  ## pieces
  mod.piece :banners, '広告バナー一覧'
end
