class Survey::AttachmentCompressService < ApplicationService
  def initialize(answers)
    @answers = answers
  end

  def compress
    require 'zip'
    steam = Zip::OutputStream.write_buffer(StringIO.new('')) do |out|
      @answers.preload(:attachment).find_each(batch_size: 10) do |answer|
        next unless attachment = answer.attachment
        out.put_next_entry("#{answer.form_answer_id}_#{answer.question.title}_#{attachment.name}")
        out.write(attachment.data)
      end
    end
    steam.string
  end
end
