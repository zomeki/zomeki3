class MigrateCmsBrackets < ActiveRecord::Migration
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
        body.scan(/\[\[(piece|text|file)\/([^\]]+)\]\]/).each do |name1, name2|
          Cms::Bracket.create(
            site_id: item.site_id,
            concept_id: item.concept_id,
            owner_id: item.id,
            owner_type: item.class,
            name: "#{name1}/#{name2}"
          )
        end
      end
    end
  end
end
