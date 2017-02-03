class Cms::Script::Base < ApplicationScript
  attr_accessor :params

  def initialize(params = {})
    self.params = params.with_indifferent_access
  end
end
