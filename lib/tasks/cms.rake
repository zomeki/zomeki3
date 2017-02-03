namespace :zomeki do
  namespace :cms do
    desc 'Clean static files'
    task :clean_statics => :environment do
      Cms::Lib::FileCleaner.clean_files
    end

    desc 'Clean empty directories'
    task :clean_directories => :environment do
      Cms::Lib::FileCleaner.clean_directories
    end

    namespace :link_check do
      desc 'Check links.'
      task :check => :environment do
        Util::LinkChecker.check
      end
    end

    namespace :nodes do
      desc 'Publish nodes'
      task :publish => :environment do
        Script.run('cms/nodes/publish')
      end
    end

    namespace :talks do
      desc 'Exec talk tasks'
      task :exec => :environment do
        Script.run('cms/talk_tasks/exec')
      end

      desc 'Clean excluded talk tasks'
      task :clean_excluded_tasks => :environment do
        ids = Zomeki.config.application['cms.use_kana_exclude_site_ids'] || []
        Cms::TalkTask.find_each{|t| t.destroy if ids.include?(t.site_id) }
      end
    end

    namespace :sites do
      desc 'Update server configs'
      task :update_server_configs => :environment do
        Cms::Site.generate_apache_configs
        Cms::Site.generate_nginx_configs
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
  end
end
