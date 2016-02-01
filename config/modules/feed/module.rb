# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :feed, 'Feed' do |mod|
  ## contents
  mod.content :feeds, 'Feed'

  ## directories
  mod.directory :feed_entries, '新着記事一覧'

  ## pieces
  mod.piece :feed_entries, '新着記事一覧'
end
