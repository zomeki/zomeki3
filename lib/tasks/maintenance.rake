namespace ZomekiCMS::NAME do
  namespace :maintenance do
    namespace :postgresql do
      desc 'Set valid value to sequences for id'
      task reset_id_sequences: :environment do
        [Sys::Creator, Sys::EditableGroup].each do |klass|
          sql = "SELECT setval('#{klass.table_name}_id_seq', coalesce((SELECT max(id) + 1 FROM #{klass.table_name}), 1), FALSE)"
          klass.connection.execute sql
        end
      end
    end

    namespace :site_dir do
      desc 'Rename site directory from 8 digit to 4 digit'
      task rename: :environment do
        Cms::Site.all.each do |site|
          dir = format('%08d', site.id).gsub(/((..)(..)(..)(..))/, '\\2/\\3/\\4/\\5/\\1')
          old_path = Rails.root.join("sites/#{dir}")
          if File.exist?(old_path)
            dir = format('%04d', site.id)
            new_path = Rails.root.join("sites/#{dir}")
            File.rename(old_path, new_path)
          end
          dir = format('%08d', site.id).gsub(/((..)(..)(..)(..))/, '\\2/\\3/\\4/\\5/\\1')
          old_path = Rails.root.join("config/mecab/sites/#{dir}")
          if File.exist?(old_path)
            dir = format('%04d', site.id)
            new_path = Rails.root.join("config/mecab/sites/#{dir}")
            File.rename(old_path, new_path)
          end
        end
      end
    end

    namespace :upload_dir do
      desc 'Rename upload directory with site id'
      task rename: :environment do
        [Sys::File, Cms::DataFile, AdBanner::Banner].each do |model|
          model.find_each do |item|
            next unless item.site_id
            site_dir = "sites/#{format('%04d', item.site_id)}"
            md_dir  = item.class.to_s.underscore.pluralize
            id_dir  = format('%08d', item.id).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
            id_file = format('%07d', item.id) + '.dat'
            old_path = Rails.root.join("upload/#{md_dir}/#{id_dir}/#{id_file}")
            if File.exist?(old_path)
              new_path = Rails.root.join("#{site_dir}/upload/#{md_dir}/#{id_dir}/#{id_file}")
              FileUtils.mkdir_p(File.dirname(new_path))
              File.rename(old_path, new_path)
            end
          end
        end
      end
    end

    namespace :common_dir do
      desc 'Copy _common directory for all sites (SITE_ID=int)'
      task copy: :environment do
        sites = Cms::Site.all
        sites.where!(id: ENV['SITE_ID']) if ENV['SITE_ID']
        sites.each do |site|
          site.copy_common_directory(force: true)
        end
      end

      desc 'Sync _common directory for all sites'
      task sync: :environment do
        Cms::Site.all.each do |site|
          com = "rsync -rlptvz --delete public/_common/ sites/#{format('%04d', site.id)}/public/_common/"
          puts com
          system com
        end
      end
    end

    namespace :publish_url do
      desc 'Set pulished Url'
      task :set => :environment do
        Rake::Task["#{ZomekiCMS::NAME}:cms:publish_urls:rebuild"].invoke
      end
    end

    namespace :files do
      desc 'Extract text content from files'
      task extract_text: :environment do
        c = Zomeki.config.application['sys.file_text_extraction']

        Zomeki.config.application['sys.file_text_extraction'] = true
        [Sys::File, Cms::DataFile].each do |klass|
          klass.find_each {|f| f.extract_text }
        end
        Sys::StorageFile.import

        Zomeki.config.application['sys.file_text_extraction'] = c
      end
    end
  end
end
