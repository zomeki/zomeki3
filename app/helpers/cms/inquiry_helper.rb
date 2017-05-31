module Cms::InquiryHelper
  def inquiry_replace(inquiry, inquiry_style)
    Cms::Public::InquiryFormatService.new(inquiry).format(inquiry_style, mobile: Page.mobile?)
  end
end
