class Cms::Public::BracketRenderService < ApplicationService
  def initialize(site, concept, mobile: nil)
    @site = site
    @concepts = if concept.is_a?(Array)
                  concept
                else
                  concept ? concept.ancestors.reverse : []
                end
    @mobile = mobile
  end

  def render_data_texts_and_files(html)
    render_data_texts(html)
    render_data_files(html)
    render_emoji(html)
    render_adobe_reader_link(html)

    html.gsub!(/\[\[[a-z]+\/[^\]]+\]\]/, '')
    html
  end

  private

  def render_data_texts(html)
    Cms::Lib::Layout.find_data_texts(html, @concepts).each do |name, item|
      html.gsub!("[[text/#{name}]]", item.body)
    end
  end

  def render_data_files(html)
    Cms::Lib::Layout.find_data_files(html, @concepts).each do |name, item|
      data = if item.image_file?
               %Q|<img src="#{item.public_uri}" alt="#{item.alt_text}" title="#{item.title}" />|
             else
               %Q|<a href="#{item.public_uri}" class="#{item.css_class}" target="_blank">#{item.united_name}</a>|
             end
      html.gsub!("[[file/#{name}]]", data)
    end
  end

  def render_emoji(html)
    html.gsub!(/\[\[emoji\/([0-9a-zA-Z\._-]+)\]\]/) do |m|
      name = m.gsub(/\[\[emoji\/([0-9a-zA-Z\._-]+)\]\]/, '\1')
      Cms::Lib::Mobile::Emoji.convert(name, @mobile)
    end
  end

  def render_adobe_reader_link(html)
    return unless html.include?('@adobe-reader-link@')

    if (@mobile && !@mobile.smart_phone?) || !@site.adobe_reader_link_enabled?
      html.gsub!('@adobe-reader-link@', '')
    else
      body = Nokogiri::HTML.fragment(html).xpath("descendant::div[@class='body']").inner_html
      link = if Util::Link.include_pdf_link?(body)
               ApplicationController.render(partial: 'cms/public/_partial/adobe_reader')
             else
               ''
             end
      html.gsub!('@adobe-reader-link@', link)
    end
  end
end
