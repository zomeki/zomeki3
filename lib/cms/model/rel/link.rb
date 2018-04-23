module Cms::Model::Rel::Link
  extend ActiveSupport::Concern

  included do
    has_many :links, class_name: 'Cms::Link', dependent: :destroy, as: :linkable
    after_save :save_links
  end

  def extract_links
    self.class.html_columns.map do |column|
      links = Util::Link.extract_links(read_attribute(column.name))
      links.each { |link| link[:column] = column.name }
      links
    end.flatten
  end

  def check_links
    ex_links = extract_links
    ex_links.map { |link|
      uri = Addressable::URI.parse(link[:url])
      url = if uri.relative?
              next unless uri.path =~ /^\//
              "#{site.full_uri.chomp('/')}#{uri.path}"
            else
              uri.to_s
            end
      res = Util::LinkChecker.check_url(url)
      { column: link[:column], body: link[:body], url: url, status: res[:status], reason: res[:reason], result: res[:result] }
    }.compact
  end

  def save_links
    links.destroy_all

    extracted_links = extract_links
    extracted_links.each do |ex_link|
      links.create(content_id: content_id, body: ex_link[:body], url: ex_link[:url], linkable_column: ex_link[:column])
    end
  end

  def backlinks
    source_url = public_uri.sub(/index\.html$/, '').sub(/\/$/, '')
    links.klass.where(linkable_type: self.class.name)
         .where(links.table[:url].matches("%#{source_url}%"))
  end

  def backlinked_items
    self.class.where(id: backlinks.pluck(:linkable_id))
  end
end
