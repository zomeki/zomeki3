class Rank::RanksScript < Cms::Script::Base
  include Rank::Controller::Rank

  def exec
    span = 3.days
    contents = Rank::Content::Rank.all
    contents = contents.where(site_id: Script.options[:site_id]) if Script.options && Script.options[:site_id]
    Script.total contents.size

    contents.each do |content|
      Script.current
      get_access(content, Time.now - span)
      calc_access(content)
      Script.success
    end
  end
end
