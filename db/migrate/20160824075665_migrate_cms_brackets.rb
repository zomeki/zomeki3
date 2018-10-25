class MigrateCmsBrackets < ActiveRecord::Migration[4.2]
  def up
    [Cms::Node, Cms::Piece, Cms::Layout].each do |model|
      model.all.each do |item|
        next if item.body.blank?
        body =
          if model == Cms::Layout
            "#{item.body}#{item.mobile_body}#{item.smart_phone_body}"
          else
            item.body
          end
        body.scan(/\[\[(\w+)\/([^\]]+)\]\]/).each do |type, name|
          Cms::Bracket.create(
            site_id: item.site_id,
            concept_id: item.concept_id,
            owner_id: item.id,
            owner_type: item.class.name,
            name: "#{type}/#{name}"
          )
        end
      end
    end
  end
end
