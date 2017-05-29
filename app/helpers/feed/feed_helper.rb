module Feed::FeedHelper
  def entry_replace(entry, entry_style, date_style, time_style = '')
    Feed::Public::EntryFormatService.new(entry).format(entry_style, date_style, time_style, mobile: Page.mobile?)
  end
end
