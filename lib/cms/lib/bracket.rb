module Cms::Lib::Bracket
  class << self
    def bracket_type(klass)
      if klass.ancestors.include?(Cms::Piece)
        'piece'
      elsif klass == Cms::DataText
        'text'
      elsif klass == Cms::DataFile
        'file'
      else
        ''
      end
    end
  end
end
