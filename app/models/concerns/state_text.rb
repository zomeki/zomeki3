module StateText
  extend ActiveSupport::Concern

  class Responder
    STATUS = {
      'enabled' => '有効',
      'disabled' => '無効',
      'visible' => '表示',
      'hidden' => '非表示',
      'draft' => '下書き',
      'recognize' => '承認待ち',
      'approvable' => '承認待ち',
      'recognized' => '公開待ち',
      'approved' => '公開待ち',
      'prepared' => '公開日時待ち',
      'public' => '公開中',
      'closed' => '非公開',
      'completed' => '完了',
      'archived' => '履歴'
    }

    def initialize(stateable, attribute_name = :state)
      @stateable = stateable
      @attribute_name = attribute_name
    end

    def name
      state = @stateable.public_send(@attribute_name)
      return '公開終了' if @stateable.is_a?(GpArticle::Doc) && state == 'closed'
      STATUS[state] || ''
    end
  end

  def status
    Responder.new(self)
  end

  def state_text
    Responder.new(self).name
  end
end
