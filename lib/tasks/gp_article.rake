namespace ZomekiCMS::NAME do
  namespace :gp_article do
    desc 'Destroy archived docs.'
    task :destroy_archived_docs => :environment do
      GpArticle::Doc.skip_callback(:destroy, :after, :close_page)
      Sys::Publisher.skip_callback(:destroy, :before, :remove_files)
      items = GpArticle::Doc.unscoped.where(state: 'archived').destroy_all
      puts "#{items.size} destroyed."
    end
  end
end
