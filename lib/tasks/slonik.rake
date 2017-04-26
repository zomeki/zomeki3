namespace :slonik do
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
        if /^create (table|sequence|view) "([^"]+)"/i.match sql
          ret = slonik_execute(sql, object: $1, object_name: $2)
          raise "failed to execute slonik command." unless ret
        elsif /^(create|alter|drop)/i.match sql
          ret = slonik_execute(sql)
          raise "failed to execute slonik command." unless ret
        else
          puts sql
          old_execute sql, name
        end
      end

      def slonik_execute(sql, options = {})
        slonik = YAML.load_file(Rails.root.join('config/slonik.yml'))[Rails.env].with_indifferent_access
        options.merge!(owner: slonik[:owner])
        command =
          if slonik[:host].present?
            ["ssh -p #{slonik[:port]} #{slonik[:user]}@#{slonik[:host]}", "'" + slonik_command(slonik[:command], sql, options) + "'"].join(' ')
          else
            slonik_command(slonik[:command], sql, options)
          end
        puts command
        system command
      end

      def slonik_command(com, sql, object: nil, object_name: nil, owner: nil)
        if object && object_name
          com.gsub('[[SQL]]', %Q|#{slonik_escape_sql(sql)}; ALTER #{object} "#{object_name}" OWNER TO #{owner}|)
        else
          com.gsub('[[SQL]]', slonik_escape_sql(sql))
        end
      end

      def slonik_escape_sql(sql)
        sql.gsub(/"/, '\"').gsub(/'/, "\'")
      end
    end
  end

  namespace :db do
    desc "Migrate with slonik"
    task :migrate => [:environment, :patch_migration] do
      Rake::Task["db:migrate"].invoke
    end
    namespace :migrate do
      task :up => [:environment, :patch_migration] do
        Rake::Task["db:migrate:up"].invoke
      end
      task :down => [:environment, :patch_migration] do
        Rake::Task["db:migrate:down"].invoke
      end
    end
  end
end
