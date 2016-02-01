# encoding: utf-8
class Feed::FeedEntry < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  include StateText

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  TARGET_OPTIONS = [['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank']]

  default_scope { order(created_at: :desc) }

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Feed::Content::Feed'
  validates :content_id, presence: true

  belongs_to :feed, :foreign_key => :feed_id, :class_name => 'Feed::Feed'

  def source_title
    return @source_title if @source_title
    if feed
      @source_title = feed.title
    else
      @source_title = nil
    end
  end

  def link_target
    feed ? "_blank" : nil
  end
  
  def new_mark
    term = content.setting_value(:new_term)
    return false if term =~ /^0(\s|$)/i

    if (term == nil || term =~ /^[\s|]*$/)
      term = 14
    end
    term = term.to_f * 60
    return false if term <= 0

    published_at = term.minutes.since self.entry_updated
    return ( published_at.to_i >= Time.now.to_i )
  end
  
  def date_and_site(options = {})
    values = []
    
    if options[:date] != false
      values << %Q(<span class="date">#{entry_updated.strftime('%Y年%-m月%-d日')}</span>) if entry_updated
    end
    
    if !source_title.blank?
      values << %Q(<span class="site">#{ERB::Util.html_escape(source_title)}</span>)
    elsif content
      suffix = content.setting_value(:doc_list_suffix)
      if suffix == "site"
        values << %Q(<span class="site">#{ERB::Util.html_escape(content.site.name)}</span>) if content.site
      end
    end
    
    return "" if values.size == 0
    
    separator = %Q(<span class="separator">　</span>)
    %Q(<span class="attributes">（#{values.join(separator)}）</span>).html_safe
  end

  def event_date_in(sdate, edate)
    self.and Condition.new do |c|
      c.or Condition.new do |c2|
        c2.and :event_date, "<", edate.to_s
        c2.and :event_close_date, ">=", sdate.to_s
      end
      c.or Condition.new do |c2|
        c2.and :event_close_date, "IS", nil
        c2.and :event_date, ">=", sdate.to_s
        c2.and :event_date, "<", edate.to_s
      end
    end
    self
  end

  def event_date_is(options = {})
    if options[:year] && options[:month]
      sd = Date.new(options[:year], options[:month], 1)
      ed = sd >> 1
      self.and :event_date, 'IS NOT', nil
      self.and :event_date, '>=', sd
      self.and :event_date, '<' , ed
    end
  end

  def public_uri
    return nil unless self.link_alternate
    self.link_alternate
  end

  def public_full_uri
    return nil unless self.link_alternate
    self.link_alternate
  end

  def agent_filter(agent)
    self
  end
  
  def category_is(cate)
    return self if cate.blank?
    cate = [cate] unless cate.class == Array
    cate.each do |c|
      if c.level_no == 1
        cate += c.public_children
      end
    end
    cate = cate.uniq

    cond = Condition.new
    added = false
    cate.each do |c|
      if c.entry_categories
        arr = c.entry_categories.split(/\r\n|\r|\n/)
        arr.each do |label|
          label = label.gsub(/\/$/, '')
          cond.or :categories, 'REGEXP', "(^|\n)#{label}"
          added = true
        end
      end
    end
    cond.and '1', '=', '0' unless added
    self.and cond
  end

end
