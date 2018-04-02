class Sys::ProcessesFinder < ApplicationFinder
  def initialize(processes)
    @processes = processes
  end

  def search(criteria)
    rel = @processes
    arel_table = @processes.klass.arel_table

    criteria.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_name'
        rel = rel.where(arel_table[:name].matches("%#{v}"))
      when 'start_date'
        start_date = Date.parse(criteria[:start_date]) rescue nil
        rel = rel.where(arel_table[:started_at].gteq(start_date)) if start_date
      when 'close_date'
        close_date = Date.parse(criteria[:close_date]) + 1.days rescue nil
        rel = rel.where(arel_table[:started_at].lteq(close_date)) if close_date
      end
    end

    rel
  end
end
