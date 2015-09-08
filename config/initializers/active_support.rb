module ActiveSupport #:nodoc:
  class SafeBuffer < String

    def safe_concat(value)
      value = force_utf8_encoding(value)
      raise SafeConcatError unless html_safe?
      original_concat(value)
    end

    def concat(value)
      value = force_utf8_encoding(value)
      if !html_safe? || value.html_safe?
        super(value)
      else
        super(ERB::Util.h(value))
      end
    end

    alias << concat

    private

    def force_utf8_encoding(value)
      self.force_encoding('UTF-8').html_safe unless self.encoding.name == 'UTF-8'
      value = (value).force_encoding('UTF-8').html_safe unless value.nil? || value.encoding.name == 'UTF-8'
      value
    end
  end

  class HashWithIndifferentAccess < Hash
    def to_s
      to_yaml
    end
  end
end
