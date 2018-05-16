class Cms::LinkCheckLogsFinder < ApplicationFinder
  def initialize(logs)
    @logs = logs
  end

  def search(criteria)
    criteria ||= {}

    @logs = @logs.search_with_text(:title, :body, :url, :reason, criteria[:keyword]) if criteria[:keyword].present?
    @logs = @logs.where(result_state: criteria[:result_state]) if criteria[:result_state].present?

    @logs = with_creator_group(criteria[:group_id]) if criteria[:group_id].present?

    @logs
  end

  private

  def with_creator_group(group_id)
    models = @logs.group(:link_checkable_type)
                  .pluck(:link_checkable_type)
                  .map(&:safe_constantize).compact
    logs = models.map do |model|
             creatable_ids = Sys::Creator.select(:creatable_id).where(creatable_type: model, group_id: group_id) 
             @logs.where(link_checkable_type: model, link_checkable_id: model.where(id: creatable_ids))
           end
    logs.compact.reduce(:union)
  end
end
