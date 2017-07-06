class Tool::Convert::PageParser
  def initialize(conf)
    @conf = conf
    @setting = conf.convert_setting
  end

  def parse(file_path, uri_path)
    page = Tool::Convert::PageInfo.new
    page.file_path = file_path
    page.uri_path = uri_path

    require 'kconv'
    html = open(page.file_path, "r:binary").read
    html = Nokogiri::HTML(html.toutf8, nil, 'utf-8')

    # title, body
    page.title = html.xpath(@setting.title_xpath).inner_text.strip
    page.body = html.xpath(@setting.body_xpath).inner_html

    # updated_at, published_at
    page.updated_at = parse_updated_at(html)
    page.published_at = parse_published_at(html)
    page.updated_at ||= ::File::stat(page.file_path).mtime.strftime("%Y-%m-%d")
    page.published_at ||= ::File::stat(page.file_path).mtime.strftime("%Y-%m-%d")

    # group_code
    page.group_code = parse_group_code(uri_path, html)

    # category_names
    page.category_names = parse_category_names(html)
    dump "抜き出しカテゴリ名：#{page.category_names}" if page.category_names.present?

    # find related objects
    page.creator_group, page.creator_user = find_group_and_user(page)
    page.categories = find_categories(page)

    page
  end

  private

  def parse_updated_at(html)
    if @setting.updated_at_xpath.present?
      updated = html.xpath(@setting.updated_at_xpath).inner_html
      if @setting.updated_at_regexp.present? && updated.to_s =~ Regexp.new(@setting.updated_at_regexp)
        "#{$1}-#{$2}-#{$3}"
      else
        updated
      end
    end
  end

  def parse_published_at(html)
    if @setting.published_at_xpath.present?
      published = html.xpath(@setting.published_at_xpath).inner_html
      if @setting.published_at_regexp.present? && published.to_s =~ Regexp.new(@setting.published_at_regexp)
        "#{$1}-#{$2}-#{$3}"
      else
        published
      end
    end
  end

  def parse_group_code(uri_path, html)
    if @setting.creator_group_from_url_regexp.present? && uri_path =~ Regexp.new(@setting.creator_group_from_url_regexp)
      group_code = $1
      @setting.creator_group_url_relations_map[group_code] || group_code
    end
  end

  def parse_category_names(html)
    if @setting.category_xpath.present? && @setting.category_regexp.present?
      html.xpath(@setting.category_xpath).inner_html.scan(Regexp.new(@setting.category_regexp)).flatten
    elsif @setting.category_xpath.present?
      html.xpath(@setting.category_xpath).to_a.map(&:inner_text)
    elsif @setting.category_regexp.present?
      html.inner_html.scan(Regexp.new(@setting.category_regexp)).flatten
    else
      []
    end
  end

  def find_group_and_user(page)
    group = Sys::Group.in_site(Core.site)
    group = if @setting.relate_url_to_group_name_en?
              group.find_by(name_en: page.group_code)
            elsif @setting.relate_url_to_group_name?
              group.find_by(name: page.group_code)
            else
              group.find_by(code: page.group_code)
            end

    user = if group
             Sys::User.in_site(Core.site).where("name like '#{group.name}%'").first
           else
             nil
           end
    return group, user
  end

  def find_categories(page)
    category_types = @conf.content.becomes(GpArticle::Content::Doc).visible_category_types

    cats = GpCategory::Category.where(category_type_id: category_types)
                               .where(title: page.category_names)

    if page.creator_group
      cats += GpCategory::Category.where(category_type_id: category_types)
                                  .where(title: group.name)
    end

    cats.uniq
  end
end
