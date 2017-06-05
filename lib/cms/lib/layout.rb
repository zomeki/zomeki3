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
      name_array = name.split('#')
      rel = Cms::Piece.select(Cms::Piece.arel_table[Arel.star])
                      .select("#{Cms::Piece.connection.quote(name)}::text as bracket_description")
                      .public_state.ci_match(name: name_array[0])
                      .order(concepts_order(concepts)).limit(1)
      if name_array.size > 1 # [[piece/name#id]]
        rel.where(id: name_array[1])
      else                   # [[piece/name]]
        rel.where(concept_id: [nil] + concepts.map(&:id))
      end
    end
    pieces = Cms::Piece.union(relations).index_by(&:bracket_description)

    if Core.mode == 'preview' && params[:piece_id]
      item = Cms::Piece.find_by(id: params[:piece_id])
      pieces[item.name] = item if item
    end

    pieces
  end

  def self.find_data_texts(html, concepts)
    names = html.scan(/\[\[text\/([0-9a-zA-Z\._-]+)\]\]/).flatten.uniq
    return {} if names.blank?

    relations = names.map do |name|
      Cms::DataText.select(Cms::DataText.arel_table[Arel.star])
                   .select("#{Cms::DataText.connection.quote(name)}::text as bracket_description")
                   .public_state.ci_match(name: name)
                   .where(concept_id: [nil] + concepts.to_a)
                   .order(concepts_order(concepts)).limit(1)
    end

    Cms::DataText.union(relations).index_by(&:bracket_description)
  end

  def self.find_data_files(html, concepts)
    names = html.scan(/\[\[file\/([^\]]+)\]\]/).flatten.uniq
    return {} if names.blank?

    relations = names.map do |name|
      dirname  = ::File.dirname(name)
      basename = dirname == '.' ? name : ::File.basename(name)

      rel = Cms::DataFile.select(Cms::DataFile.arel_table[Arel.star])
                         .select("#{Cms::DataFile.connection.quote(name)}::text as bracket_description")
                         .public_state.ci_match(name: basename)
                         .where(concept_id: [nil] + concepts.to_a)
                         .order(concepts_order(concepts, table_name: Cms::DataFile.table_name)).limit(1)
      if dirname == '.'
        rel.where(node_id: nil)
      else
        rel.joins(:node).merge(Cms::DataFileNode.ci_match(name: dirname))
      end
    end

    Cms::DataFile.union(relations).index_by(&:bracket_description)
  end
end
