# encoding: utf-8
require 'builder'
module Feed::Controller::Feed
  def render_feed(docs)
    if ['rss', 'atom'].index(params[:format])
      @skip_layout = true
      @site_uri    = Page.site.full_uri
      @node_uri    = @site_uri.gsub(/\/$/, '') + Page.current_node.public_uri
      @req_uri     = @site_uri.gsub(/\/$/, '') + Page.uri
      @feed_name   = "#{Page.title} | #{Page.site.name}"
      @entry_ids   = {}
      
      data = nil
      if params[:format] == "rss"
        data = to_rss(docs) 
      elsif params[:format] == "atom"
        data = to_atom(docs) 
      end
      return render :xml => unescape(data)
    end
    return false
  end

  def unescape(xml)
    xml = xml.to_s
    #xml = CGI.unescapeHTML(xml)
    #xml = xml.gsub(/&amp;/, '&')
    xml.gsub(/&#(?:(\d*?)|(?:[xX]([0-9a-fA-F]{4})));/) { [$1.nil? ? $2.to_i(16) : $1.to_i].pack('U') }
  end

  def strimwidth(str, size, options = {})
    suffix = options[:suffix] || '..'
    str    = str.sub!(/<[^<>]*>/,"") while /<[^<>]*>/ =~ str
    chars  = str.split(//u)
    return chars.size <= size ? str : chars.slice(0, size).join('') + suffix
  end

  def to_rss(docs)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.rss('version' => '2.0') do

      xml.channel do
        xml.title       @feed_name
        xml.link        @req_uri
        xml.language    "ja"
        xml.description Page.title

        docs.each do |entry|
          xml.item do
            xml.title        entry.title
            xml.link         entry.public_full_uri
            xml.description  strimwidth(entry.summary.to_s.gsub(/&nbsp;/, ' '), 500)
            xml.pubDate      entry.entry_updated.rfc822
            unless entry.image_uri.blank?
              xml.enclosure :url => entry.image_uri, :type => entry.image_type, :length => entry.image_length
            end
            
            entry.categories.split(/\r\n|\r|\n/).each do |label|
              next if label =~ /\// && label !~ /^分野\//
              xml.category   label.gsub(/.*\//, '')
            end
          end
        end #docs

      end #channel
    end #xml
  end
  
  def to_atom(docs)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct! :xml, :version => 1.0, :encoding => 'UTF-8'
    xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do

      updated = (docs[0] && docs[0].try(:published_at)) ? docs[0].published_at : Date.today
      
      xml.id      "tag:#{Page.site.domain},#{Page.site.created_at.strftime('%Y')}:#{Page.current_node.public_uri}"
      xml.title   @feed_name
      xml.updated updated.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1')
      xml.link    :rel => 'alternate', :href => @node_uri
      xml.link    :rel => 'self', :href => @req_uri, :type => 'application/atom+xml', :title => @feed_name

      docs.each do |doc|
        @entry_id = doc.id
        next if @entry_ids[@entry_id]
        @entry_ids[@entry_id] = true
        
        xml.entry do
          to_atom_entry(xml, doc)
        end #entry
      end #docs
    end #feed
  end
  
  def to_atom_entry(xml, entry)
    xml.id      @entry_id
    xml.title   entry.title
    xml.updated entry.entry_updated.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1') #.rfc822
    xml.summary(:type => 'html') do |p|
      p.cdata! strimwidth(entry.summary, 500)
    end
    xml.link      :rel => 'alternate', :href => entry.public_full_uri

    unless entry.image_uri.blank?
      xml.link :rel => 'enclosure', :href => entry.image_uri, :type => entry.image_type, :length => entry.image_length
    end
    
    entry.categories.split(/\r\n|\r|\n/).each do |label|
      xml.category :label => label
    end
    
    xml.author do |auth|
      auth.name  entry.author_name
      auth.email entry.author_email if entry.author_email
    end if entry.author_name
  end
end