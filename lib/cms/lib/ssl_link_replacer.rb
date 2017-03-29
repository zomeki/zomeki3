class Cms::Lib::SslLinkReplacer
  attr_reader :site, :current_path

  def run(html, site:, current_path:, ssl_paths: nil)
    @site = site
    @current_path = current_path

    ssl_paths ||= load_common_ssl_paths
    return html if ssl_paths.blank?

    @ssl_paths_regexp = Regexp.new("\\A#{ssl_paths.join('|')}")
    @current_path_is_ssl = !!(@current_path =~ @ssl_paths_regexp)

    doc = Nokogiri::HTML(html)
    replaced = replace_links(doc)
    replaced ? doc.to_s : html
  end

  private

  def load_common_ssl_paths
    ssl_content_ids = Cms::Content.select(:id).joins(:settings)
                                  .where(model: 'Survey::Form', site_id: @site.id)
                                  .where(cms_content_settings: { name: 'common_ssl', value: 'enabled' })
    Cms::Node.where(content_id: ssl_content_ids, model: 'Survey::Form').map(&:public_uri)
  end

  def replace_links(doc)
    full_ssl_uri = @site.full_ssl_uri.chomp('/')
    full_uri = @site.full_uri.chomp('/')
    file_regexp = /^\/_(common|layouts|themes|file|emfiles)/
    replaced = false

    %w(href action src).each do |attr|
      doc.css(%Q![#{attr}^="/"]!).each do |n|
        next if n[attr] =~ %r!^//!

        if n[attr] =~ @ssl_paths_regexp
          n[attr] = "#{full_ssl_uri}#{n[attr]}"
          replaced = true
        elsif @current_path_is_ssl
          if n[attr] =~ file_regexp
            n[attr] = "#{full_ssl_uri}#{n[attr]}"
          else
            n[attr] = "#{full_uri}#{n[attr]}"
          end
          replaced = true
        end
      end
    end
    replaced
  end
end
