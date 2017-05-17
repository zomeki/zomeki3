namespace :zomeki do
  namespace :sys do
    desc 'Delete duplicated values. (leave only latest values.)'
    task :clean_sequence => :environment do
      Sys::Sequence.transaction do
        before_key = {}
        Sys::Sequence.order(name: :asc, version: :asc, id: :desc).each do |sequence|
          if before_key[:name] == sequence.name && before_key[:version] == sequence.version
            sequence.destroy
            puts "[DELETED] name: #{sequence.name}, version: #{sequence.version}"
          else
            before_key[:name], before_key[:version] = sequence.name, sequence.version
          end
        end
      end
    end

    desc 'Cleanup unnecessary data.'
    task :cleanup => :environment do
      Sys::File.cleanup
    end

    namespace :tasks do
      desc 'Exec tasks'
      task :exec => :environment do
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('sys/tasks/exec', site_id: site_id, lock_by: :site)
        end
      end
    end
  end
end
