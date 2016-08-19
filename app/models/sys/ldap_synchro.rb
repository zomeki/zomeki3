class Sys::LdapSynchro < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Tree
  include Sys::Model::Auth::Manager
  
  validates :version, :entry_type, :code, :name, presence: true
  
  def children
    return @_children if @_children
    @_children = self.class.where(version: version, parent_id: id, entry_type: 'group').order(:sort_no, :code)
  end
  
  def users
    return @_users if @_users
    @_users = self.class.where(version: version, parent_id: id, entry_type: 'user').order(:sort_no, :code)
  end
  
  def group_count
    self.class.where(version: version, entry_type: 'group').count
  end
  
  def user_count
    self.class.where(version: version, entry_type: 'user').count
  end
end
