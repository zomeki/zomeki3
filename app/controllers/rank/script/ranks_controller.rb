class Rank::Script::RanksController < ApplicationController
  include Rank::Controller::Rank

  def exec
    span = 3.days
    contents = Rank::Content::Rank.all
    
    Script.total contents.size

    contents.each do |content|
      Script.current
      get_access(content, Time.now - span)
      calc_access(content)
      Script.success
    end
    render(:text => "OK")
  end

end
