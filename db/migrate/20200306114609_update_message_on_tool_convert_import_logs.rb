class UpdateMessageOnToolConvertImportLogs < ActiveRecord::Migration[5.0]
  def up
    Tool::ConvertImport.all.each do |import|
      next if import.log.blank?
      
      import.logs.destroy_all
      
      lines = import.log.lines
      lines.each_slice(20){|v| import.dump v.join('').chomp }
      
      import.update_column(:log, '')
    end
  end

  def down
  end
end
