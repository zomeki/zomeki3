module Cms::Lib::Layout
  def self.current_concept
    concept = defined?(Page.current_item.concept) ? Page.current_item.concept : nil
    concept ||= Page.current_node.inherited_concept
  end
  
  def self.inhertited_concepts
    return [] unless current_concept
    current_concept.parents_tree.reverse
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

  def self.find_design_pieces(html, concepts)
    names = html.scan(/\[\[piece\/([^\]]+)\]\]/).map{|n| n[0] }.uniq

    items = {}
    names.each do |name|
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
      if item = rel.order(concepts_order(concepts)).first
        items[name] = item
      end
    end
    return items
  end
  
  def self.find_data_texts(html, concepts)
    names = html.scan(/\[\[text\/([0-9a-zA-Z\._-]+)\]\]/).flatten
    
    items = {}
    names.uniq.each do |name|
      item = Cms::DataText.public_state.where(name: name, concept_id: [nil] + concepts.to_a)
        .order(concepts_order(concepts)).first
      items[name] = item if item
    end
    return items
  end
  
  def self.find_data_files(html, concepts)
    names = html.scan(/\[\[file\/([^\]]+)\]\]/).flatten
    
    items = {}
    names.uniq.each do |name|
      dirname  = ::File.dirname(name)
      basename = dirname == '.' ? name : ::File.basename(name)
      
      item = Cms::DataFile.public_state.where(name: basename, concept_id: [nil] + concepts.to_a)

      if dirname == '.'
        item = item.where(node_id: nil)
      else
        nodes = Cms::DataFileNode.arel_table
        item = item.joins(:node).where(nodes[:name].eq(dirname))
      end
      item = item.order(concepts_order(concepts, :table_name => Cms::DataFile.table_name)).first

      items[name] = item if item
    end
    return items
  end
end
