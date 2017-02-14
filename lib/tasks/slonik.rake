namespace :slonik do
  task :check_slonik_command do
    sh 'which slonik'
    sh 'which slonik_execute_script'
  end
  task :patch_migration do
    # disable transaction
    ActiveRecord::Migrator.class_eval do
      private
      def use_transaction?(migration)
        false
      end
    end
    # call slonic_execute_script
    ActiveRecord::Base.connection.class.class_eval do
      alias :old_execute :execute
      def execute(sql, name = nil)
        if /^(create|alter|drop)/i.match sql
          command = %Q{slonik_execute_script -c "#{sql.gsub(/"/, '\"')}" 1 | sed "s/set id = 1,//" | slonik}
          puts command
          system command
        else
          puts sql
          old_execute sql, name
        end
      end
    end
  end

  namespace :db do
    desc "Migrate with slonik"
    task :migrate => [:environment, :check_slonik_command, :patch_migration] do
      Rake::Task["db:migrate"].invoke
    end
    namespace :migrate do
      task :up => [:environment, :check_slonik_command, :patch_migration] do
        Rake::Task["db:migrate:up"].invoke
      end
      task :down => [:environment, :check_slonik_command, :patch_migration] do
        Rake::Task["db:migrate:down"].invoke
      end
    end
  end
end
