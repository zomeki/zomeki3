module Sys::Model::Scope
  extend ActiveSupport::Concern

  included do
    scope :search_with_text, ->(*args) {
      words = args.pop.to_s.split(/[ 　]+/)
      columns = args
      where(words.map{|w| columns.map{|c| arel_table[c].matches("%#{w.gsub(/([_%])/,'\\\\\1')}%") }.reduce(:or) }.reduce(:and))
    }
  end
end
