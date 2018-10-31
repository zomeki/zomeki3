class CreateSysOperationLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :sys_operation_logs do |t|
      t.belongs_to :loggable, polymorphic: true

      t.references :user
      t.string :operation

      t.timestamps
    end
  end
end
