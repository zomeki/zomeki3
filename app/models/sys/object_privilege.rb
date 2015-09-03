# encoding: utf-8
class Sys::ObjectPrivilege < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager

  belongs_to :unid_original, :foreign_key => 'item_unid', :class_name => 'Sys::Unid'
  belongs_to :concept, :foreign_key => 'item_unid', :primary_key => 'unid', :class_name => 'Cms::Concept'
  belongs_to :role_name, :foreign_key => 'role_id', :class_name => 'Sys::RoleName'

  validates :role_id, :item_unid, presence: true
  validates :action, presence: true, if: %Q(in_actions.blank?)

  attr_accessor :in_actions

  def in_actions
    unless @in_actions
      @in_actions = actions
    end
    @in_actions
  end

  def in_actions=(values)
    @_in_actions_changed = true
    _values = []
    unless values.blank?
      values.each {|key, val| _values << key unless val.blank? }
      @in_actions = _values
    else
      @in_actions = values
    end
  end

  def action_labels(format = nil)
    list = [['閲覧','read'], ['作成','create'], ['編集','update'], ['削除','delete']]
    if format == :hash
      h = {}
      list.each {|c| h[c[1]] = c[0]}
      return h
    end
    list
  end

  def privileges
    self.class.where(:role_id => role_id, :item_unid => item_unid).order(:action)
  end
  
  def actions
    privileges.collect{|c| c.action}
  end
  
  def action_names
    names = []
    _actions = actions
    action_labels.each do |label, key|
      if actions.index(key)
        names << label
        _actions.delete(key)
      end
    end
    names += _actions
    names
  end
  
  def save
    return super unless @_in_actions_changed
    return false unless valid?
    save_actions
  end
  
  def destroy_actions
    privileges.each {|priv| priv.destroy }
    return true
  end
  
protected
  def save_actions
    values = in_actions.clone
    
    old_privileges = self.class.where(role_id: role_id, item_unid: (self.item_unid_was || self.item_unid)).order(:action)
    old_privileges.each do |priv|
      if values.index(priv.action)
        if item_unid != priv.item_unid
          priv.item_unid = item_unid
          priv.save
        end
      else
        priv.destroy
      end
      values.delete(priv.action)
    end
    
    values.each do |value|
      Sys::ObjectPrivilege.new({
        :role_id    => role_id,
        :item_unid  => item_unid,
        :action     => value
      }).save
    end
    
    return true
  end
end
