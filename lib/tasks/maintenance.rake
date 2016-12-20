namespace :zomeki do
  namespace :maintenance do
    desc 'Replace @title@ to @title_link@ in settings'
    task(:replace_title_with_title_link => :environment) do
      ccs = Cms::ContentSetting.arel_table
      Cms::ContentSetting.where(ccs[:value].matches('%@title@%')).each do |cs|
        info_log "#{cs.content.class.name}(#{cs.content_id}):#{cs.content.name}"
        cs.update_column(:value, cs.value.gsub('@title@', '@title_link@'))
      end

      cps = Cms::PieceSetting.arel_table
      Cms::PieceSetting.where(cps[:value].matches('%@title@%')).each do |ps|
        info_log "#{ps.piece.class.name}(#{ps.piece_id}):#{ps.piece.title}(#{ps.piece.name})"
        ps.update_column(:value, ps.value.gsub('@title@', '@title_link@'))
      end

      gctm = GpCategory::TemplateModule.arel_table
      GpCategory::TemplateModule.where(gctm[:doc_style].matches('%@title@%')).each do |tm|
        info_log "#{tm.class.name}(#{tm.id}):#{tm.title}(#{tm.name})"
        tm.update_column(:doc_style, tm.doc_style.gsub('@title@', '@title_link@'))
      end
    end

    desc 'Clean invalid links'
    task(:clean_invalid_links => :environment) do
      count = 0
      GpArticle::Link.find_each do |l|
        next if l.doc && l.doc.state_public?
        l.destroy
        count += 1
      end
      puts count > 0 ? "#{count} invalid links removed." : 'No invalid links.'
    end

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
      desc 'Copy _common directory for all sites'
      task copy: :environment do
        Cms::Site.all.each do |site|
          site.send(:force_copy_common_directory)
        end
      end
    end

    namespace :publish_url do
      desc 'Set pulished Url'
      task(:set => :environment) do
        Cms::Node::Page.record_timestamps = false
        GpArticle::Doc.record_timestamps = false

        Cms::Node::Page.public_state.each(&:save)
        GpArticle::Doc.public_state.each(&:save)

        Cms::Node::Page.record_timestamps = true
        GpArticle::Doc.record_timestamps = true
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
