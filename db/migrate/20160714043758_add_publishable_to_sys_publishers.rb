class AddPublishableToSysPublishers < ActiveRecord::Migration[4.2]
  def up
    add_reference :sys_publishers, :publishable, index: true, polymorphic: true
  end

  def down
    remove_reference :sys_publishers, :publishable, index: true, polymorphic: true
  end
end
