class Sys::Reorg::RecognitionService < ReorgService
  def initialize
    @model = Sys::Recognition
  end

  def reorganize_user(user_map)
     make_user_id_map(user_map).tap do |id_map|
      id_map.each do |(src, dst), ids|
        @model.where(id: ids).find_each do |r|
          info = r.info(src.id)
          next if info.recognized_at.present?

          info.id = dst.id
          info.save

          r.recognizer_ids = r.info(:all).map(&:id).join(' ')
          r.save 
        end
      end
    end
  end

  private

  def make_user_id_map(user_map)
    user_map.each_with_object({}) do |(src, dst), id_map|
      ids = @model.with_recognizer(src.id).order(:id).pluck(:id)
      id_map[[src, dst]] = ids if ids.present?
    end
  end
end
