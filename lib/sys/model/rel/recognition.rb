module Sys::Model::Rel::Recognition
  extend ActiveSupport::Concern

  included do
    has_one :recognition, class_name: 'Sys::Recognition', dependent: :destroy, as: :recognizable
    before_save :prepare_recognition
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

  def recognized?
    state == 'recognized'
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
      update_columns(state: 'recognized', recognized_at: Core.now)
    end
    return rs
  end

  private

  def validate_recognizers
    errors["承認者"] = "を入力してください。" if in_recognizer_ids.blank?
  end

  def prepare_recognition
    return true unless @_in_recognizer_ids_changed

    rec = recognition || build_recognition
    rec.user_id        = Core.user.id
    rec.recognizer_ids = in_recognizer_ids.strip
    rec.info_xml       = nil
    rec.save

    rec.reset_info

    self.recognized_at = nil

    return true
  end
end
