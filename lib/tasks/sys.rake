namespace ZomekiCMS::NAME do
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
      Sys::UsersSession.cleanup
      Sys::Process.cleanup
    end

    namespace :tasks do
      desc 'Exec tasks'
      task :exec => :environment do
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('sys/tasks/exec', site_id: site_id, lock_by: :site)
        end
      end

      desc 'Rebuild jobs for task (SITE_ID=int)'
      task :rebuild_jobs => :environment do
        tasks = Sys::Task.where(state: 'queued').order(process_at: :asc)
        tasks = tasks.in_site(ENV['SITE_ID']) if ENV['SITE_ID']
        tasks.preload(:processable).each do |task|
          if task.processable && task.processable.state.in?(%w(recognized approved prepared public))
            task.enqueue_job
          end
        end
      end
    end

    namespace :publishers do
      desc 'Clean publishers (SITE_ID=int)'
      task :clean => :environment do
        items = Sys::Publisher
        items = items.in_site(Cms::Site.find(ENV['SITE_ID'])) if ENV['SITE_ID']
        items.find_each(&:destroy)
      end

      desc 'Clean ruby publishers (SITE_ID=int)'
      task :clean_rubies => :environment do
        items = Sys::Publisher
        items = items.in_site(Cms::Site.find(ENV['SITE_ID'])) if ENV['SITE_ID']
        items.with_ruby_dependent.find_each(&:destroy)
      end

      desc 'Clean talk publishers (SITE_ID=int)'
      task :clean_talks => :environment do
        items = Sys::Publisher
        items = items.in_site(Cms::Site.find(ENV['SITE_ID'])) if ENV['SITE_ID']
        items.with_talk_dependent.find_each(&:destroy)
      end

      desc 'Rebuild publishers'
      task :rebuild => :environment do
        Cms::Site.order(:id).each do |site|
          Sys::Publisher.in_site(site).delete_all
          node_ids = Cms::Node.public_state.rebuildable_models
                              .where(site_id: site.id)
                              .pluck(:id)
          Cms::RebuildJob.perform_later(site_id: site.id, target_node_ids: node_ids)
          content_ids = Cms::Content.distinct.rebuildable_models.joins(:nodes)
                                    .where(site_id: site.id)
                                    .where(Cms::Node.arel_table[:state].eq('public'))
                                    .pluck(:id)
          content_ids.each do |content_id|
            Cms::RebuildJob.perform_later(site_id: site.id, target_content_ids: [content_id])
          end 
        end
      end
    end
  end
end
