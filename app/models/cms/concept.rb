class Cms::Concept < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Role
  include Sys::Model::Tree
  include Sys::Model::Base::Page
  include Sys::Model::Auth::Manager

  include StateText

  has_many :children, -> { order(:sort_no) },
    :foreign_key => :parent_id, :class_name => 'Cms::Concept', :dependent => :destroy
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Cms::Concept'
  has_many :layouts, -> { order(:name) },
    :foreign_key => :concept_id, :class_name => 'Cms::Layout', :dependent => :destroy
  has_many :pieces, -> { order(:name) },
    :foreign_key => :concept_id, :class_name => 'Cms::Piece', :dependent => :destroy
  has_many :contents, -> { order(:name) },
    :foreign_key => :concept_id, :class_name => 'Cms::Content', :dependent => :destroy
  has_many :data_files , :foreign_key => :concept_id,
    :class_name => 'Cms::DataFile', :dependent => :destroy
  has_many :data_file_nodes , :foreign_key => :concept_id,
    :class_name => 'Cms::DataFileNode', :dependent => :destroy
  
  validates :site_id, :state, :level_no, :name, presence: true

  validate {
    errors.add :parent_id, :invalid if id != nil && id == parent_id
  }

  def tree_name(opts = {})
    opts.reverse_merge!(prefix: '　　', depth: 0)
    opts[:prefix] * [level_no - 1 + opts[:depth], 0].max + name
  end

  def targets
    [['現在のコンセプトから','current'], ['すべてのコンセプトから','all']]
  end

  def readable_children(site = Core.site, user = Core.user)
    rel = self.class.where(state: 'public', site_id: site.id, parent_id: id.to_i)

    unless user.has_auth?(:manager)
      rel = rel.where(id: Sys::ObjectPrivilege.select(:concept_id).where(
        action: 'read', role_id: Sys::UsersRole.select(:role_id).where(user_id: user.id)
      ))
    end

    rel.order(:sort_no)
  end

  def self.find_by_path(path)
    return nil if path.to_s == ''
    parent_id = 0
    item = nil
    path.split('/').each do |name|
      unless item = self.where(parent_id: parent_id, name: name).order(:id).first
        return nil
      end
      parent_id = item.id
    end
    return item
  end
  
  def path
    path = name
    id = self.parent_id
    lo = 0
    while item = Cms::Concept.find_by(id: id) do
      id = item.parent_id
      path = item.name + '/' + path
      lo += 1
      if lo > 100
        path = nil
        break
      end
    end if id > 0
    path
  end
  
  def candidate_parents
    concepts = Core.site.root_concepts
    concepts = concepts.where.not(id: id) if id
    concepts = concepts.map{|c| c.descendants{|child| child.where.not(id: id) if id } }.flatten(1)
    concepts.map{|c| [c.tree_name, c.id] }
  end
end
