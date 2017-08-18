class Tool::Convert
  SITE_BASE_DIR = "#{Rails.application.root.to_s}/wget_sites"
  HTML_FILE_EXTS = %w(htm html shtml php asp jsp)

  def self.download_site(conf)
    return if conf.site_url.blank?

    site_dir = ::File.join(SITE_BASE_DIR, conf.site_url_without_scheme)
    FileUtils.rm_rf(site_dir) if File.exist?(site_dir)

    com = "wget -rqN --restrict-file-names=nocontrol -P #{SITE_BASE_DIR} #{conf.site_url}"
    com << " -I #{conf.include_dir}" if conf.include_dir.present?
    com << " -l #{conf.recursive_level}" if conf.recursive_level
    system com
  end

  def self.htmlfiles(site_url, options = {})
    root_dir = ::File.join(SITE_BASE_DIR, site_url).to_s
    return [] unless File.exist?(root_dir)

    dir = if options[:include_child_dir]
            "#{root_dir}/**"
          else
            root_dir
          end

    file_paths = Dir["#{dir}/*.{#{HTML_FILE_EXTS.join(',')}}*"].uniq.sort

    if options[:only_filenames].present?
      file_paths.select! do |file_path|
        uri_path = Pathname(file_path).relative_path_from(Pathname(SITE_BASE_DIR)).to_s
        options[:only_filenames].include?(uri_path)
      end
    end

    file_paths
  end

  def self.import_site(conf)
    file_paths = htmlfiles(conf.site_url, include_child_dir: true, only_filenames: conf.site_filename.presence || nil)

    conf.total_num = file_paths.size
    conf.save

    conf.dump "書き込み処理開始: #{conf.total_num}件"

    processed_doc_ids = []
    file_paths.each_with_index do |file_path, i|
      uri_path = Pathname(file_path).relative_path_from(Pathname(SITE_BASE_DIR)).to_s
      conf.dump "--- #{uri_path}"
      page = Tool::Convert::PageParser.new(conf).parse(file_path, uri_path)

      if page.kiji_page?
        conf.dump ["タイトル: #{page.title}",
                   "更新日: #{page.updated_at}",
                   "公開日: #{page.published_at}",
                   "作成者グループ: #{page.group_code}",
                   "カテゴリ: #{page.category_names.join(', ')}"].join("\n")

        db = Tool::Convert::DbProcessor.new(conf).process(page)
        processed_doc_ids << db.doc.id if db.doc

        case db.process_type
        when 'created'
          conf.created_num += 1
        when 'updated'
          conf.updated_num += 1
        when 'nonupdated'
          conf.nonupdated_num += 1
        end

        conf.dump "更新区分: #{db.process_type_label}"
        if db.process_type != 'nonupdated'
          conf.dump ["記事ID: #{db.doc.id}",
                     "記事ディレクトリ: #{db.doc.name}",
                     "記事作成者グループ: #{db.doc.creator.try(:group).try(:name)}",
                     "記事作成者ユーザー: #{db.doc.creator.try(:user).try(:name)}", 
                     "記事カテゴリ: #{db.doc.categories.map(&:title).join(', ')}"].join("\n")
        end
      else
        conf.skipped_num += 1
        conf.dump "非記事: #{'タイトル' if page.title.blank?}#{'本文' if page.body.blank?}無し"
      end

      conf.save if i % 100 == 0
    end

    if conf.overwrite == 1
      conf.dump "--- 記事非公開処理"
      docs = GpArticle::Doc.where(content_id: conf.content_id).where.not(id: processed_doc_ids)
      docs.each do |doc|
        doc.close
        conf.dump "記事非公開: #{doc.id} #{doc.title}"
      end
    end

    conf.dump "書き込み処理終了\n"
    conf.save
  end

  def self.process_link(conf, updated_at = nil)
    items = Tool::ConvertDoc.in_site(Core.site).where(content_id: conf.content_id)
    items = items.where('updated_at >= ?', updated_at) if updated_at
    items = items.order('id')

    conf.link_total_num = items.count
    conf.save

    conf.dump "リンク解析処理開始: #{conf.link_total_num}件"
    items.find_in_batches(batch_size: 10) do |cdocs|
      cdocs.each do |cdoc|
        conf.link_processed_num += 1
        conf.dump "--- #{cdoc.uri_path}"

        if doc = cdoc.latest_doc
          Tool::Convert::LinkProcessor.new(conf).sublink(cdoc)
        else
          conf.dump "記事検索失敗"
        end

        conf.save if conf.link_processed_num % 100 == 0
      end
    end

    conf.dump "リンク解析処理終了"
    conf.save
  end
end
