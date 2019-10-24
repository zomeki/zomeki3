class Rank::RankDeleteJob < ApplicationJob
  def perform(content)
    @content = content

    delete_old_ranks
  end

  def delete_old_ranks
    ActiveRecord::Base.transaction do
      dt = (Date.today - 3.month) - 1
      Rank::Rank.where(content_id: @content.id)
                .where(Rank::Rank.arel_table[:date].lteq(dt.strftime('%F')))
                .delete_all
    end
  end
end
