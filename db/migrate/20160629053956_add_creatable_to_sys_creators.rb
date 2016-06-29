class AddCreatableToSysCreators < ActiveRecord::Migration
  KLASSES = [
    AdBanner::Banner,
    AdBanner::Group,
    BizCalendar::BussinessHoliday,
    BizCalendar::BussinessHour,
    BizCalendar::ExceptionHoliday,
    BizCalendar::HolidayType,
    BizCalendar::Place,
    Cms::Concept,
    Cms::Content,
    Cms::DataFile,
    Cms::DataFileNode,
    Cms::DataText,
    Cms::Feed,
    Cms::KanaDictionary,
    Cms::Layout,
    Cms::Node,
    Cms::Piece,
    Cms::Site,
    Cms::SiteBasicAuthUser,
    Feed::Feed,
    Gnav::MenuItem,
    GpArticle::Doc,
    GpCalendar::Event,
    GpCalendar::Holiday,
    GpCategory::Category,
    GpCategory::CategoryType,
    GpTemplate::Template,
    Organization::Group,
    Survey::Form,
    Sys::File,
    Sys::Maintenance,
    Sys::Message,
  ]

  def up
    add_reference :sys_creators, :creatable, index: true, polymorphic: true
    KLASSES.each do |klass|
      klass.find_each {|o| o.creator ||= Sys::Creator.find_by(id: o.unid) }
    end
  end

  def down
    remove_reference :sys_creators, :creatable, index: true, polymorphic: true
  end
end
