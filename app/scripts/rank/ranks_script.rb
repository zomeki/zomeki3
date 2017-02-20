class Rank::RanksScript < Cms::Script::Base
  include Rank::Controller::Rank

  def exec
    contents = Rank::Content::Rank.all
    contents = contents.where(site_id: ::Script.site.id) if ::Script.site

    ::Script.total contents.size

    contents.each do |content|
      ::Script.progress(content) do
        get_access(content, Time.now - 3.days)
        calc_access(content)
      end
    end
  end
end
