class ByteLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attr, value)
    return if value.blank?

    current_size = value.bytesize
    if current_size > options[:maximum]
      record.errors.add(message_attribute(record) || attr,
                        options[:message] || :too_long_byte,
                        limit: options[:maximum],
                        current_size: current_size)
    end
  end

  private

  def message_attribute(record)
    if options[:attribute].is_a?(Proc)
      record.instance_exec(&options[:attribute])
    else
      options[:attribute]
    end
  end
end
