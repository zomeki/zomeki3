class Sys::ProcessLog < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :user, :class_name => 'Sys::User'
  belongs_to :parent, :foreign_key => :parent_id ,:class_name => 'Sys::Process'
  attr_accessor :title

  def summary_lael
    Sys::Process::PROCESSE_LIST.each{|a| return a[0] if a[1] == name}
    return nil
  end

  def to_base_model
    item = Sys::Process.new(attributes.except(self.class.primary_key, 'parent_id'))
    item
  end

  scope :search_with_params, ->(params = {}) {
    rel = all
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_id'
        rel.where!(id: v)
      when 's_user_id'
        rel.where!(user_id: v)
      when 's_name'
        rel.where!(name: v)
      when 'start_date'
        rel.where!(arel_table[:started_at].gteq(v))
      when 'close_date'
        date = Date.strptime(params[:close_date], "%Y-%m-%d") + 1.days rescue nil
        rel.where!(arel_table[:started_at].lteq(date)) if date
      end
    end
    rel
  }

end
