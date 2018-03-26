class GpArticle::PreviewDocsFinder < ApplicationFinder
  def initialize(user)
    @user = user
  end

  def search(preview_at)
    tasks = Sys::Task.select(:processable_id)
                     .where(processable_type: 'GpArticle::Doc', state: 'queued')
                     .date_before(:process_at, preview_at)
    publiches = tasks.where(name: 'publish')
    closes = tasks.where(name: 'close')

    publics = GpArticle::Doc.select(:id).where(state: 'public')
    nonpublics = GpArticle::Doc.select(:id).where(state: %w(approvable approved prepared), id: publiches)

    unless @user.has_auth?(:manager)
      creators = Sys::Creator.arel_table
      nonpublics = nonpublics.joins(:creator).where(creators[:group_id].eq(@user.group.id))
    end

    docs = [GpArticle::Doc.where(id: publics),
            GpArticle::Doc.where(id: nonpublics)].reduce(:or).where.not(id: closes)

    GpArticle::Doc.where(id: docs.select("MAX(id) as id").group(:name))
  end
end
