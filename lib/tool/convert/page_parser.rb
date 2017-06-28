class Tool::Convert::PageParser
  def parse(file_path, uri_path, conf)
    page = Tool::Convert::PageInfo.new
    page.file_path = file_path
    page.uri_path = uri_path

    require 'kconv'
    html = open(page.file_path, "r:binary").read
    html = Nokogiri::HTML(html.toutf8, nil, 'utf-8')

    # title, body
    page.title = html.xpath(conf.title_xpath).inner_text.strip
    page.body = html.xpath(conf.body_xpath).inner_html

    # updated_at, published_at
    page.updated_at = parse_updated_at(html, conf)
    page.published_at = parse_published_at(html, conf)
    page.updated_at ||= ::File::stat(page.file_path).mtime.strftime("%Y-%m-%d")
    page.published_at ||= ::File::stat(page.file_path).mtime.strftime("%Y-%m-%d")

    # group
    page.group_code = parse_group_code(uri_path, html, conf)
    set_page_group_info(page, conf, page.group_code) if page.group_code.present?

    # category
    page.category_names = parse_category_names(html, conf)
    dump "抜き出しカテゴリ名：#{page.category_names}" if page.category_names.present?

    page
  end

  private

  def parse_updated_at(html, conf)
    if conf.updated_at_xpath.present?
      updated = html.xpath(conf.updated_at_xpath).inner_html
      if conf.updated_at_regexp.present? && updated.to_s =~ Regexp.new(conf.updated_at_regexp)
        "#{$1}-#{$2}-#{$3}"
      else
        updated
      end
    end
  end

  def parse_published_at(html, conf)
    if conf.published_at_xpath.present?
      published = html.xpath(conf.published_at_xpath).inner_html
      if conf.published_at_regexp.present? && published.to_s =~ Regexp.new(conf.published_at_regexp)
        "#{$1}-#{$2}-#{$3}"
      else
        published
      end
    end
  end

  def parse_group_code(uri_path, html, conf)
    if conf.creator_group_from_url_regexp.present? && uri_path =~ Regexp.new(conf.creator_group_from_url_regexp)
      group_code = $1
      conf.creator_group_url_relations_map[group_code] || group_code
    end
  end

  def set_page_group_info(page, conf, group_code)
    group = 
      if conf.relate_url_to_group_name_en?
        Sys::Group.find_by(name_en: group_code)
      elsif conf.relate_url_to_group_name?
        Sys::Group.find_by(name: group_code)
      else
        Sys::Group.find_by(code: group_code)
      end

    if group
      page.creator_group_id = group.id
      page.creator_user_id = Sys::User.where("name like '#{group.name}%'").first.try(:id)

      page.inquiry_group_id = group.id
      page.inquiry_group_tel = group.tel
      page.inquiry_group_fax = group.fax
      page.inquiry_group_email = group.email

      if category = GpCategory::Category.where(title: group.name).first
        page.category_ids = [category.id]
      end
    end
  end

  def parse_category_names(html, conf)
    if conf.category_xpath.present? && conf.category_regexp.present?
      html.xpath(conf.category_xpath).inner_html.scan(Regexp.new(conf.category_regexp)).flatten
    elsif conf.category_xpath.present?
      html.xpath(conf.category_xpath).to_a.map(&:inner_text)
    elsif conf.category_regexp.present?
      html.inner_html.scan(Regexp.new(conf.category_regexp)).flatten
    else
      []
    end
  end
end
