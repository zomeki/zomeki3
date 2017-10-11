namespace ZomekiCMS::NAME do
  namespace :cms do
    desc 'Clean static files'
    task :clean_statics => :environment do
      Cms::Lib::FileCleaner.clean_files
    end

    desc 'Clean empty directories'
    task :clean_directories => :environment do
      Cms::Lib::FileCleaner.clean_directories
    end

    namespace :link_checks do
      desc 'Check links'
      task :exec => :environment do
        Cms::Site.order(:id).each do |site|
          if site.link_check_hour?(Time.now.hour)
            system("bundle exec rake #{ZomekiCMS::NAME}:cms:link_checks:exec_site SITE_ID=#{site.id} RAILS_ENV=#{Rails.env} &")
          end
        end
      end

      desc 'Check links in specified site'
      task :exec_site => :environment do
        site = Cms::Site.find_by(id: ENV['SITE_ID'])
        Script.run('cms/link_checks/exec', site_id: site.id, lock_by: :site, kill: 12.hours.to_i) if site
      end
    end

    namespace :nodes do
      desc 'Publish nodes'
      task :publish => :environment do
        next if Zomeki.config.application['cms.file_publisher'] == false
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('cms/nodes/publish', site_id: site_id, lock_by: :site)
        end
      end
    end

    namespace :talks do
      desc 'Exec talk tasks'
      task :exec => :environment do
        next if Zomeki.config.application['cms.file_publisher'] == false
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('cms/talk_tasks/exec', site_id: site_id, lock_by: :global)
        end
      end
    end

    namespace :file_transfers do
      desc 'Exec file transfers'
      task :exec => :environment do
        next unless Zomeki.config.application['cms.file_transfer']
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('cms/file_transfers/exec', site_id: site_id, lock_by: :site)
        end
      end
    end

    namespace :sites do
      desc 'Update server configs'
      task :update_server_configs => :environment do
        out1 = `bundle exec rails g cms:nginx:site_config --force`
        puts out1
        out2 = `bundle exec rails g cms:apache:site_config --force`
        puts out2
        if (out1 + out2) =~ /^\s*(force|create|remove)/
          Cms::Site.reload_servers
        end
      end
    end

    namespace :data_files do
      desc 'Rebuild data files'
      task :rebuild => :environment do
        Cms::DataFile.where(state: 'public').find_each do |item|
          item.upload_public_file
        end
      end
    end

    namespace :brackets do
      desc 'Rebuild brackets'
      task :rebuild => :environment do
        [Cms::Layout, Cms::Node, Cms::Piece, GpArticle::Doc].each do |model|
          model.find_each do |item|
            item.save_brackets
          end
        end
      end
    end

    namespace :links do
      desc 'Rebuild links'
      task :rebuild => :environment do
        [Cms::Node::Page, GpArticle::Doc].each do |model|
          model.find_each do |item|
            item.save_links
          end
        end
      end
    end

    namespace :publish_urls do
      desc 'Rebuild publish urls'
      task :rebuild => :environment do
        Cms::Node::Page.public_state.find_each(&:set_public_name)
        GpArticle::Doc.public_state.find_each(&:set_public_name)
      end
    end

    namespace :search_texts do
      desc 'Rebuild search texts'
      task :rebuild => :environment do
        [Cms::Node::Page, GpArticle::Doc].each do |model|
          items = model
          items = items.where(model: 'Cms::Page') if model == Cms::Node::Page
          items.find_each do |item|
            item.rebuild_search_texts
          end
        end
      end
    end
  end
end
