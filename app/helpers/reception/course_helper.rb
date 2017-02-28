module Reception::CourseHelper
  def course_replace(course, doc_style, datetime_style)

    contents = {
      title: -> { course_replace_title(course) },
      subtitle: -> { course_replace_subtitle(course) },
      summary: -> { course_replace_summary(course) },
      total_number: -> { course_replace_total_number(course) },
      charge: -> { course_replace_charge(course) },
      remarks: -> { course_replace_remarks(course) },
      hold_date: -> { course_replace_hold_date(course, datetime_style) },
      place: -> { course_replace_place(course) },
      name: -> { course_replace_name(course) },
      link: -> { course_replace_link(course) },
      category: -> { course_replace_category(course) },
    }

    if Page.mobile?
      contents[:link].call
    else
      doc_style = doc_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
      doc_style.html_safe
    end
  end

  private

  def course_replace_title(course)
    if course.title.present?
      content_tag(:span, course.title, class: 'title')
    end
  end

  def course_replace_subtitle(course)
    if course.subtitle.present?
      content_tag(:span, course.subtitle, class: 'subtitle')
    end
  end

  def course_replace_summary(course)
    if course.body.present?
      content_tag(:span, course.body.html_safe, class: 'summary')
    end
  end

  def course_replace_total_number(course)
    if course.capacity.present?
      content_tag(:span, course.capacity, class: 'total_number')
    end
  end

  def course_replace_charge(course)
    if course.fee.present?
      content_tag(:span, course.fee, class: 'charge')
    end
  end

  def course_replace_remarks(course)
    if course.remark.present?
      content_tag(:span, course.remark.html_safe, class: 'remarks')
    end
  end

  def course_replace_hold_date(course, datetime_style)
    open = course.public_opens.select(&:applicable?).first
    if open && open.open_on
      ds = localize_wday(datetime_style, open.open_on.wday)
      content_tag(:span, open.open_on_start_at.strftime(ds), class: 'hold_date')
    end
  end

  def course_replace_place(course)
    open = course.public_opens.select(&:applicable?).first
    if open && open.place.present?
      content_tag(:span, open.place, class: 'place')
    end
  end

  def course_replace_name(course)
    open = course.public_opens.select(&:applicable?).first
    if open && open.lecturer.present?
      content_tag(:span, open.lecturer, class: 'name')
    end
  end

  def course_replace_link(course)
    link = link_to(course.title, course.public_uri)
    if link.present?
      content_tag(:span, link, class: 'link')
    end
  end

  def course_replace_category(course)
    categories = course.categories
    if categories.present?
      category_text = categories.map { |c|
        content_tag(:span, c.title, class: "#{c.category_type.name}-#{c.ancestors.map(&:name).join('-')}")
      }.join.html_safe
      content_tag(:span, category_text, class: 'category')
    end
  end
end
