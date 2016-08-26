module Cms::Lib::Bracket
  class << self
    def bracket_type(item)
      case
      when item.is_a?(Cms::Piece)
        'piece'
      when item.is_a?(Cms::DataText)
        'text'
      when item.is_a?(Cms::DataFile)
        item.node ? "file/#{item.node.name}" : 'file'
      else
        ''
      end
    end
  end
end
