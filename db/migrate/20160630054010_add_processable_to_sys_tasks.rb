class AddProcessableToSysTasks < ActiveRecord::Migration
  KLASSES = [
    Cms::Node,
    GpArticle::Doc,
    Survey::Form,
  ]

  def up
    add_reference :sys_tasks, :processable, index: true, polymorphic: true
    KLASSES.each do |klass|
      klass.find_each {|o| o.tasks = Sys::Task.where(unid: o.unid) }
    end
  end

  def down
    remove_reference :sys_tasks, :processable, index: true, polymorphic: true
  end
end
