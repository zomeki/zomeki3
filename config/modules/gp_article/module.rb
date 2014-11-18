# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :gp_article, '記事' do |mod|
  ## contents
  mod.content :docs, '記事'

  ## directories
  mod.directory :docs, '記事ページ'
  mod.directory :archives, 'アーカイブ一覧'

  ## pieces
  mod.piece :docs, '記事一覧'
  mod.piece :recent_tabs, '新着タブ'
  mod.piece :monthly_archives, '月間アーカイブ'
  mod.piece :comments, '最新コメント'
end
