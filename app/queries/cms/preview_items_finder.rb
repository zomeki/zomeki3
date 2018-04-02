class Cms::PreviewItemsFinder < ApplicationFinder
  def initialize(model, user)
    @user = user
    @model = model
  end

  def search(preview_at)
    tasks = Sys::Task.select(:processable_id)
                     .where(processable_type: @model.name, state: 'queued')
                     .date_before(:process_at, preview_at)
    publiches = tasks.where(name: 'publish')
    closes = tasks.where(name: 'close')

    publics = @model.select(:id).where(state: 'public')
    nonpublics = @model.select(:id).where(state: %w(approvable approved prepared), id: publiches)

    unless @user.has_auth?(:manager)
      creators = Sys::Creator.arel_table
      nonpublics = nonpublics.joins(:creator).where(creators[:group_id].eq(@user.group.id))
    end

    items = [@model.where(id: publics),
             @model.where(id: nonpublics)].reduce(:or).where.not(id: closes)

    @model.where(id: items.select('MAX(id) as id').group(:name).reorder(nil))
  end
end
