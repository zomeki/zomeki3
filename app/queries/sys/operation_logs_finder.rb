class Sys::OperationLogsFinder < ApplicationFinder
  def initialize(logs)
    @logs = logs
  end

  def search(criteria)
    rel = @logs
    arel_table = @logs.klass.arel_table

    criteria.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_user_account'
        rel = rel.where(user_account: v)
      when 's_action'
        rel = rel.where(action: v == 'recognize' ? ['recognize', 'approve'] : v)
      when 's_keyword'
        rel = rel.search_with_text(:item_name, :item_model, v)
      when 'start_date'
        start_date = Date.parse(criteria[:start_date]) rescue nil
        rel = rel.where(arel_table[:created_at].gteq(start_date)) if start_date
      when 'close_date'
        close_date = Date.parse(criteria[:close_date]) + 1.days rescue nil
        rel = rel.where(arel_table[:created_at].lteq(close_date)) if close_date
      end
    end

    rel
  end
end
