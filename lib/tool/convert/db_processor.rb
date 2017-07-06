class Tool::Convert::DbProcessor
  PROCESS_TYPES = [['作成', 'created'], ['更新', 'updated'], ['非更新', 'nonupdated']]
  attr_reader :doc, :cdoc, :process_type

  def initialize(conf)
    @conf = conf
  end

  def process_type_label
    PROCESS_TYPES.rassoc(@process_type).try(:first)
  end

  def process(page)
    # 更新チェック
    if @cdoc = Tool::ConvertDoc.in_site(Core.site).where(uri_path: page.uri_path).first
      if @doc = @cdoc.latest_doc
        if @conf.overwrite == 0 && !page.updated_from?(@cdoc.page_updated_at)
          @process_type = 'nonupdated'
          return self
        else
          @process_type = 'updated'
        end
      else
        @doc = @conf.content.model.constantize.new(content_id: @conf.content_id)
        @process_type = 'created'
      end
    else
      @cdoc = Tool::ConvertDoc.new
      @doc = @conf.content.model.constantize.new(content_id: @conf.content_id)
      @process_type = 'created'
    end

    dump @process_type

    @doc.state ||= @conf.doc_state
    @doc.filename_base = page.doc_filename_base if @doc.new_record? && @conf.keep_filename == 1
    @doc.content_id = @conf.content.id if @conf.content
    @doc.concept_id = @conf.content.concept_id if @conf.content
    @doc.title = page.title
    @doc.body = page.body
    @doc.created_at ||= page.updated_at || Time.now
    @doc.updated_at ||= page.updated_at || Time.now
    @doc.published_at = page.published_at || Time.now
    @doc.display_updated_at = page.updated_at || Time.now
    @doc.display_published_at = page.published_at || Time.now
    @doc.recognized_at = page.updated_at || Time.now
    @doc.href ||= ''
    @doc.subtitle ||= ''
    @doc.summary ||= ''
    @doc.mobile_title ||= ''
    @doc.mobile_body ||= ''

    site_manager = @conf.content.site.managers.first
    @doc.build_creator unless @doc.creator
    @doc.creator.group = page.creator_group || site_manager.try(:groups).try(:first) || Core.user_group
    @doc.creator.user = page.creator_user || site_manager || Core.user

    if @doc.inquiries.blank? && page.creator_group.present?
      @doc.inquiries.build(
        state: 'visible',
        group_id: page.creator_group.id,
        tel: page.creator_group.tel,
        fax: page.creator_group.fax,
        email: page.creator_group.email
      )
    end

    @doc.in_ignore_accessibility_check = '1'
    @doc.in_ignore_link_check = '1'

    if @doc.save
      @doc.category_ids = (@doc.category_ids + page.category_ids).uniq
      dump "設定カテゴリ：#{@doc.categories.map(&:title).join(', ')}"
    else
      dump "記事保存失敗"
      dump @doc.errors.full_messages
      @process_type = 'error'
      return self
    end

    @cdoc.content = @doc.content
    @cdoc.docable = @doc
    @cdoc.doc_name = @doc.name
    @cdoc.doc_public_uri = @doc.public_uri
    @cdoc.published_at = @doc.published_at
    @cdoc.site_url = @conf.site_url
    @cdoc.uri_path = page.uri_path
    @cdoc.file_path = page.file_path
    @cdoc.title = page.title
    @cdoc.body = page.body
    @cdoc.page_updated_at = page.updated_at
    @cdoc.page_group_code = page.group_code
    @cdoc.updated_at = Time.now

    unless @cdoc.save
      dump "変換記事保存失敗"
      dump @cdoc.errors.full_messages
      @process_type = 'error'
      return self
    end

    return self
  end
end
