class Cms::NodesFinder < ApplicationFinder
  def initialize(nodes)
    @nodes = nodes
  end

  def search(criteria)
    criteria ||= {}

    criteria.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_state'
        @nodes = @nodes.where(state: v)
      when 's_title'
        @nodes = @nodes.search_with_text(:title, v)
      when 's_body'
        @nodes = @nodes.search_with_text(:body, v)
      when 's_directory'
        @nodes = @nodes.where(directory: v)
      end
    end

    @nodes
  end
end
