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
    page.updated_at = parse_updated_at(html) || ::File::stat(page.file_path).mtime.strftime("%Y-%m-%d %H:%M")
    page.published_at = parse_published_at(html) || ::File::stat(page.file_path).mtime.strftime("%Y-%m-%d %H:%M")

    # group_code
    page.group_code = parse_group_code(html, uri_path)

    # category_names
    page.category_names = parse_category_names(html)

    # find related objects
    page.creator_group, page.creator_user = find_group_and_user(page)
    page.categories = find_categories(page)

    page
  end

  private

  def parse_as_array_text(html, xpath, regexp)
    if xpath.present? && regexp.present?
      html.xpath(xpath).inner_html.scan(Regexp.new(regexp)).flatten
    elsif xpath.present?
      html.xpath(xpath).to_a.map(&:inner_html)
    elsif regexp.present?
      html.inner_html.scan(Regexp.new(regexp)).flatten
    end
  end

  def parse_as_date(html, xpath, regexp)
    strs = parse_as_array_text(html, @setting.updated_at_xpath, @setting.updated_at_regexp)
    [strs[0..2].to_a.join('-'), strs[3..4].to_a.join(':')].select(&:present?).join(' ') if strs
  end

  def parse_updated_at(html)
    parse_as_date(html, @setting.updated_at_xpath, @setting.updated_at_regexp)
  end

  def parse_published_at(html)
    parse_as_date(html, @setting.published_at_xpath, @setting.published_at_regexp)
  end

  def parse_group_code(html, uri_path)
    group_code = parse_as_array_text(html, @setting.creator_group_xpath, @setting.creator_group_regexp)
    group_code = group_code.try(:first) 

    if group_code.blank? && @setting.creator_group_from_url_regexp.present?
      group_code = uri_path.scan(Regexp.new(@setting.creator_group_from_url_regexp)).flatten.first
    end

    @setting.creator_group_relations_map[group_code] || group_code
  end

  def parse_category_names(html)
    category_names = parse_as_array_text(html, @setting.category_xpath, @setting.category_regexp) || []
    category_names.map do |name|
      @setting.category_relations_map[name] || name
    end
  end

  def find_group_and_user(page)
    group = Sys::Group.in_site(Core.site)
    group = case @setting.creator_group_relation_type.to_i
            when 0
              group.find_by(code: page.group_code)
            when 1
              group.find_by(name: page.group_code)
            when 2
              group.find_by(name_en: page.group_code)
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
                                  .where(title: page.creator_group.name)
    end

    cats.uniq
  end
end
