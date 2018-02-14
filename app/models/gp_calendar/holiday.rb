class GpCalendar::Holiday < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  # Pseudo event attributes
  attr_accessor :href, :name, :note, :categories, :files, :image_files
  # Not saved to database
  attr_accessor :doc

  enum_ish :state, [:public, :closed], default: :public
  enum_ish :kind, [:holiday, :event], default: :holiday

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCalendar::Content::Event'
  validates :content_id, :presence => true

  # Proper
  validates :state, :presence => true

  after_initialize :set_defaults

  after_save     Cms::Publisher::ContentCallbacks.new(belonged: true), if: :changed?
  before_destroy Cms::Publisher::ContentCallbacks.new(belonged: true)

  validates :title, :presence => true

  scope :public_state, -> { where(state: 'public') }

  scope :content_and_criteria, ->(content, criteria){
    holidays = self.arel_table

    rel = self.where(holidays[:content_id].eq(content.id))
    rel = rel.where(holidays[:title].matches("%#{criteria[:title]}%")) if criteria[:title].present?
    rel = rel.where("TO_CHAR(date, 'MMDD') = ? and ( (repeat = false and TO_CHAR(date, 'YYYY') = ?) or (repeat = true) )",
      "#{criteria[:date].strftime('%m%d')}", "#{criteria[:date].strftime('%Y')}") if criteria[:date].present?
    rel = rel.where(holidays[:kind].eq(criteria[:kind])) if criteria[:kind].present?
    rel = case criteria[:order]
          when 'created_at_desc'
            rel.except(:order).order(holidays[:created_at].desc)
          when 'created_at_asc'
            rel.except(:order).order(holidays[:created_at].asc)
          else
            rel
          end
    if (year_month = criteria[:year_month]) =~ /^(\d{6}|\d{4})$/
      case year_month
      when /^\d{6}$/
        start_date = Date.new(year_month.slice(0, 4).to_i, year_month.slice(4, 2).to_i, 1)
        end_date = start_date.end_of_month
      when /^\d{4}$/
        start_date = Date.new(year_month.to_i, 1, 1)
        end_date = start_date.end_of_year
      end

      if start_date && end_date
        rel = rel.where("(repeat = false and TO_CHAR(date, 'YYYYMMDD') >= ? and TO_CHAR(date, 'YYYYMMDD') <= ?) or (repeat = true and TO_CHAR(date, 'MMDD') >= ? and TO_CHAR(date, 'MMDD') <= ?)",
          "#{start_date.strftime('%Y%m%d')}", "#{end_date.strftime('%Y%m%d')}", "#{start_date.strftime('%m%d')}", "#{end_date.strftime('%m%d')}")
      end
    end

    return rel
  }

  def started_on=(year)
    @started_on = Date.new(year, self.date.month, self.date.day) if self.date.present?
  end

  def started_on
    @started_on
  end

  def ended_on
    self.started_on
  end

  def holiday
    criteria = {date: started_on, kind: 'holiday'}
    GpCalendar::Holiday.public_state.content_and_criteria(content, criteria).first.try(:title)
  end

  private

  def set_defaults
    # event attributes
    self.categories ||= []
    self.files ||= []
    self.image_files ||= []
  end
end
