class Sys::ObjectPrivilege < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Auth::Site::Role

  belongs_to :privilegable, polymorphic: true
  belongs_to :concept, class_name: 'Cms::Concept'
  belongs_to :role_name, :foreign_key => 'role_id', :class_name => 'Sys::RoleName'

  after_save :save_actions
  after_destroy :destroy_actions

  validates :role_id, :concept_id, presence: true
  validates :action, presence: true, if: %Q(in_actions.blank?)

  attr_accessor :in_actions

  def in_actions
    @in_actions ||= actions
  end

  def in_actions=(values)
    @_in_actions_changed = true
    @in_actions = if values.kind_of?(Hash)
                    values.map{|k, v| k if v.present? }.compact
                  else
                    []
                  end
  end

  def action_labels
    [['閲覧','read'], ['作成','create'], ['編集','update'], ['削除','delete']]
  end

  def privileges
    self.class.where(role_id: role_id, privilegable_id: privilegable_id, privilegable_type: privilegable_type).order(:action)
  end
  
  def actions
    privileges.map(&:action)
  end
  
  def action_names
    _actions = actions
    action_labels.map { |label, name| _actions.include?(name) ? label : nil }.compact
  end

  private

  def save_actions
    return unless @_in_actions_changed

    privileges.destroy_all

    actions = in_actions.map(&:to_s)
    actions.each do |action|
      priv = self.class.where(role_id: role_id, concept_id: concept_id, action: action).first_or_initialize
      priv.privilegable = concept
      priv.save
    end
  end

  def destroy_actions
    privileges.destroy_all
  end
end
