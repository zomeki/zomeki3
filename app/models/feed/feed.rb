class Feed::Feed < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  include StateText

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  TARGET_OPTIONS = [['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank']]

  default_scope { order(created_at: :desc) }

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Feed::Content::Feed'
  validates :content_id, presence: true

  has_many   :entries,        :foreign_key => :feed_id,         :class_name => 'Feed::FeedEntry',
    :dependent => :destroy

  validates :name, presence: true
  validates :title, presence: true
  validates :uri, presence: true

  after_initialize :set_defaults

  def safe(alt = nil, &block)
    begin
      yield
    rescue NoMethodError => e
      if e.respond_to? :args and (e.args.nil? or (!e.args.blank? and e.args.first.nil?))
        alt
      end
    end
  end

  def request_feed
    res = Util::Http::Request.send(uri)
    if res.status != 200
      errors.add :base, "RequestError: #{uri}"
      return nil
    end
    return res.body
  end

  def update_feed(options = {})
    unless xml = request_feed
      errors.add :base, "FeedRequestError: #{uri}"
      return false
    end

    if options[:destroy] == true
      entries.destroy_all
    end
    
    require "rexml/document"
    doc  = REXML::Document.new(xml)
    root = doc.root
    if root.name.downcase =~ /^(rss|rdf)$/
      return update_feed_rss(root)
    else
      return update_feed_atom(root)
    end
    
  rescue => e
    dump "Error: #{e.class}"
    errors.add :base, "Error: #{e.class}"
    return false
  end
  
  def update_feed_rss(root)
    latest = []
    
    channel = root.elements['channel']
    self.feed_id        = nil
    self.feed_type      = root.name.downcase
    self.feed_updated   = Core.now
    self.feed_title     = channel.elements['title'].text
    self.link_alternate = channel.elements['link'].text
    self.entry_count ||= 20
    self.save
    
    ## entries
    begin
      path = root.elements["item"]  ? "item" : "channel/item"
      root.elements.each(path) do |e|
        entry_id      = e.elements['link'].text
        entry_updated = (e.elements['pubDate'] || e.elements['dc:date']).text
        
        cond  = {:feed_id => self.id, :entry_id => entry_id}
        if entry = Feed::FeedEntry.new.find(:first, :conditions => cond)
          arr = Date._parse(entry_updated, false).values_at(:year, :mon, :mday, :hour, :min, :sec, :zone, :wday)

          newt = Time::local(*arr[0..-3]).strftime('%s').to_i
          oldt = entry.entry_updated.strftime('%s').to_i
          if newt <= oldt
            latest << entry.id
            next
          end
        else
          entry = Feed::FeedEntry.new
        end
        
        ## base
        entry.content_id       = self.content_id
        entry.feed_id          = self.id
        entry.state          ||= 'public'
        entry.entry_id         = entry_id
        entry.entry_updated    = entry_updated
        entry.title            = safe{e.elements['title'].texts.join}
        entry.summary          = safe{e.elements['description'].texts.join}
        entry.link_alternate   = e.elements['link'].text
        if e.elements['enclosure']
          enclosure = e.elements['enclosure']
          entry.image_uri = enclosure.attribute('url').to_s if enclosure.attribute('type').to_s =~ /^image*/
        end
        
        ## category xml
        if fixed_categories_xml.blank?
          cates = []
          e.each_element('category') {|c| cates << c.to_s }
          entry.categories_xml = cates.join("\n")
        else
          entry.categories_xml = fixed_categories_xml
        end
        
        ## category
        set_entry_category(entry)
        
        ## save
        latest << entry.id if entry.save
        break if latest.size >= self.entry_count
      end
    rescue Exception => e
      dump "FeedEntryError: #{e}"
      errors.add :base, "FeedEntryError: #{e}"
    end

    if latest.size > 0
      cond = Condition.new
      cond.and "NOT id", "IN", latest
      cond.and :feed_id, self.id
      Feed::FeedEntry.destroy_all(cond.where)
    end
    return errors.size == 0
  end
  
  def update_feed_atom(root)
    latest = []
    
    ## feed
    self.feed_id      = root.elements['id'].text
    self.feed_type    = "atom"
    self.feed_updated = root.elements['updated'].text
    self.feed_title   = root.elements['title'].text
    root.each_element('link') do |l|
      self.link_alternate = l.attribute('href').to_s if l.attribute('rel').to_s == 'alternate'
    end
    self.entry_count ||= 20
    self.save

    ## entries
    begin
      root.get_elements('entry').each_with_index do |e, i|
        break if i >= self.entry_count

        entry_id      = e.elements['id'].text
        entry_updated = e.elements['updated'].text

        cond  = {:feed_id => self.id, :entry_id => entry_id}
        if entry = Feed::FeedEntry.new.find(:first, :conditions => cond)
          arr  = Date._parse(entry_updated, false).values_at(:year, :mon, :mday, :hour, :min, :sec, :zone, :wday)
          newt = Time::local(*arr[0..-3]).strftime('%s').to_i
          oldt = entry.entry_updated.strftime('%s').to_i
          if newt <= oldt
            latest << entry.id
            next
          end
        else
          entry = Feed::FeedEntry.new
        end

        ## base
        entry.content_id       = self.content_id
        entry.feed_id          = self.id
        entry.state          ||= 'public'
        entry.entry_id         = entry_id
        entry.entry_updated    = entry_updated
        entry.title            = safe{e.elements['title'].texts.join}
        entry.summary          = safe{e.elements['summary'].texts.join}

        ## links
        e.each_element('link') do |l|
          entry.link_alternate = l.attribute('href').to_s if l.attribute('rel').to_s == 'alternate'
          if l.attribute('rel').to_s == 'enclosure'
            entry.link_enclosure = l.attribute('href').to_s
            if l.attribute('type').to_s =~ /^image*/
              entry.image_uri    = l.attribute('href').to_s
              entry.image_type   = l.attribute('type').to_s
              entry.image_length = l.attribute('length').to_s
            end
          end
          
        end

        ## category xml
        if fixed_categories_xml.blank?
          cates = []
          e.each_element('category') {|c| cates << c.to_s }
          entry.categories_xml = cates.join("\n")
        else
          entry.categories_xml = fixed_categories_xml
        end
        
        ## category
        set_entry_category(entry)
        
        ## author
        if author = e.elements['author']
          entry.author_name    = safe{author.elements['name'].text}
          entry.author_email   = safe{author.elements['email'].text}
          entry.author_uri     = safe{author.elements['uri'].text}
        end
        
        ## save
        latest << entry.id if entry.save
      end
    rescue Exception => e
      errors.add :base, "FeedEntryError: #{e}"
    end

    if latest.size > 0
      cond = Condition.new
      cond.and "NOT id", "IN", latest
      cond.and :feed_id, self.id
      Feed::FeedEntry.destroy_all(cond.where)
    end
    return errors.size == 0
  end

  def set_entry_category(entry)
    labels = []
    entry.categories_xml.to_s.scan(/<category [^>]*?label=['"](.*?)['"][^>]+>/) do |m|
      labels << m[0].to_s.gsub(/ /, '_')
    end
    entry.categories_xml.to_s.scan(/<category>(.*?)<\/category>/) do |m|
      labels << m[0].to_s.gsub(/ /, '_')
    end
    entry.categories = labels.join("\n")
    
    entry.event_date = nil
    entry.categories_xml.to_s.scan(/<category [^>]*term=['"]event['"].*>/) do |m|
      next if m !~ /イベント\/\d{4}-\d{2}-\d{2}T/
      year, month, day = m.match(/イベント\/(\d{4})-(\d{2})-(\d{2})T/).to_a.values_at(1, 2, 3)
      if year && month && day
        entry.event_date = Date.new(year.to_i, month.to_i, day.to_i) rescue nil
      end
    end
  end

  private

  def set_defaults
    self.state       ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
    self.entry_count ||= 20 if self.has_attribute?(:entry_count)
  end
  
end
