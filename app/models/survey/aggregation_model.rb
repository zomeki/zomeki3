class Survey::AggregationModel
  include ActiveModel::Model

  attr_accessor :question, :sums

  def initialize(attrs = {})
    self.sums = {}
    super
  end
end
