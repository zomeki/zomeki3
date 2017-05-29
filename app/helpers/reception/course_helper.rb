module Reception::CourseHelper
  def course_replace(course, doc_style, datetime_style)
    Reception::Public::CourseFormatService.new(course).format(doc_style, datetime_style, mobile: Page.mobile?)
  end
end
