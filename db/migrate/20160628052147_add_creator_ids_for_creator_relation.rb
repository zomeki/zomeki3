class AddCreatorIdsForCreatorRelation < ActiveRecord::Migration
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
    KLASSES.each do |klass|
      add_column klass.table_name, :creator_id, :integer, index: true
      klass.find_each {|c| c.update_column(:creator_id, c.unid) }
    end
  end

  def down
    KLASSES.reverse.each do |klass|
      remove_column klass.table_name, :creator_id
    end
  end
end
