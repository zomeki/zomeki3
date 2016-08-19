module Sys::Model::Rel::Recognition
  def self.included(mod)
    mod.has_one :recognition, class_name: 'Sys::Recognition', dependent: :destroy, as: :recognizable
    mod.after_save :save_recognition
  end

  def in_recognizer_ids
    @in_recognizer_ids ||= recognizer_ids.to_s
  end

  def in_recognizer_ids=(ids)
    @_in_recognizer_ids_changed = true
    @in_recognizer_ids = ids.to_s
  end

  def recognizer_ids
    recognition ? recognition.recognizer_ids : ''
  end
  
  def recognizers
    recognition ? recognition.recognizers : []
  end
  
  def join_recognition
    join :recognition
  end
  
  def recognized?
    return state == 'recognized'
  end

  def recognizable?(user = nil)
    return false unless recognition
    return false unless state == "recognize"
    recognition.recognizable?(user)
  end

  def recognize(user)
    return false unless recognition
    rs = recognition.recognize(user)
    
    if state == 'recognize' && recognition.recognized_all?
      sql = "UPDATE #{self.class.table_name} SET state = 'recognized', recognized_at = '#{Core.now}' WHERE id = #{id}"
      self.state = 'recognized'
      self.recognized_at = Core.now
      self.class.connection.execute(sql)
    end
    return rs
  end

private
  def validate_recognizers
    errors["承認者"] = "を入力してください。" if in_recognizer_ids.blank?
  end
  
  def save_recognition
    return true unless @_in_recognizer_ids_changed
    return false if @sent_save_recognition
    @sent_save_recognition = true

    unless (rec = recognition)
      rec = Sys::Recognition.new
      rec.recognizable = self
    end

    rec.user_id        = Core.user.id
    rec.recognizer_ids = in_recognizer_ids.strip
    rec.info_xml       = nil
    rec.save

    rec.reset_info

    self.update_attribute(:recognized_at, nil)

    return true
  end
end
