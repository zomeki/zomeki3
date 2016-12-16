module Cms::Lib::Layout
  def self.current_concept
    concept = defined?(Page.current_item.concept) ? Page.current_item.concept : nil
    concept ||= Page.current_node.inherited_concept
  end

  def self.inhertited_concepts
    return [] unless current_concept
    current_concept.ancestors.reverse
  end

  def self.inhertited_layout
    layout = defined?(Page.current_item.layout) ? Page.current_item.layout : nil
    layout ||= Page.current_node.inherited_layout
  end

  def self.concepts_order(concepts, options = {})
    return 'concept_id' if concepts.blank?

    table = options.has_key?(:table_name) ? options[:table_name] + '.' : ''
    order = "CASE #{table}concept_id"
    concepts.each_with_index {|c, i| order += " WHEN #{c.id} THEN #{i}"}
    order += " ELSE 100 END, #{table}id"
  end

  def self.find_design_pieces(html, concepts, params)
    names = html.scan(/\[\[piece\/([^\]]+)\]\]/).map{|n| n[0] }.uniq
    return {} if names.blank?

    relations = names.map do |name|
      rel = Cms::Piece.where(state: 'public')
      name_array = name.split('#')
      rel = if name_array.size > 1 # [[piece/name#id]]
              rel.where(id: name_array[1], name: name_array[0])
            else                   # [[piece/name]]
              concept_ids = concepts.map(&:id)
              concept_ids << nil
              rel.where(name: name_array[0])
                 .where(concept_id: concept_ids)
            end
      rel.select("*, #{Cms::DataFile.connection.quote(name)}::text as name_with_option")
        .order(concepts_order(concepts)).limit(1)
    end
    dump relations
    if Core.mode == 'preview' && params[:piece_id]
      item = Cms::Piece.where(id: params[:piece_id])
        .select("*, name as name_with_option").limit(1)
      relations << item if item
    end

    Cms::Piece.union(relations).index_by(&:name_with_option)
  end

  def self.find_data_texts(html, concepts)
    names = html.scan(/\[\[text\/([0-9a-zA-Z\._-]+)\]\]/).flatten.uniq
    return {} if names.blank?

    relations = names.map do |name|
      Cms::DataText.public_state.where(name: name, concept_id: [nil] + concepts.to_a)
        .order(concepts_order(concepts)).limit(1)
    end

    Cms::DataText.union(relations).index_by(&:name)
  end

  def self.find_data_files(html, concepts)
    names = html.scan(/\[\[file\/([^\]]+)\]\]/).flatten.uniq
    return {} if names.blank?

    relations = names.map do |name|
      dirname  = ::File.dirname(name)
      basename = dirname == '.' ? name : ::File.basename(name)

      item = Cms::DataFile.select(Cms::DataFile.arel_table[Arel.star])
        .select("#{Cms::DataFile.connection.quote(name)} as name_with_option")
        .public_state.where(name: basename, concept_id: [nil] + concepts.to_a)

      if dirname == '.'
        item = item.where(node_id: nil)
      else
        item = item.joins(:node).where(Cms::DataFileNode.arel_table[:name].eq(dirname))
      end
      item.order(concepts_order(concepts, :table_name => Cms::DataFile.table_name)).limit(1)
    end

    Cms::DataFile.union(relations).index_by(&:name_with_option)
  end
end
