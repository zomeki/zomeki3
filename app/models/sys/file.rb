class Sys::File < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator

  belongs_to :file_attachable, polymorphic: true

  ## garbage collect
  def self.garbage_collect
    self.where.not(tmp_id: nil).where(parent_unid: nil)
      .where(arel_table[:created_at].lt(Date.strptime(Core.now, "%Y-%m-%d") - 2)).destroy_all
  end
  
  ## Remove the temporary flag.
  def self.fix_tmp_files(tmp_id, parent_unid)
    self.where(parent_unid: nil, tmp_id: tmp_id).update_all(parent_unid: parent_unid, tmp_id: nil)
  end

  def duplicated
    c_tmp_id, c_parent_unid = (tmp_id ? [tmp_id, nil] : [nil, parent_unid])

    files = self.class.arel_table

    self.class.where(name: name).where(files[:id].not_eq(id).and(files[:tmp_id].eq(c_tmp_id))
                                                            .and(files[:parent_unid].eq(c_parent_unid))).first
  end

  def duplicated?
    !!duplicated
  end

  def parent
    unid = Sys::Unid.find(self.parent_unid)
    unid.model.constantize.find(unid.item_id)
  end
end
