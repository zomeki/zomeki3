namespace :unicorn do
  desc "Start unicorn"
  task start: :environment do
    config = "#{Rails.root}/config/unicorn/#{Rails.env}.rb"
    sh "bundle exec unicorn_rails -c #{config} -E #{Rails.env} -D"
  end

  desc "Stop unicorn"
  task stop: :environment do
    unicorn_signal :QUIT
  end

  desc "Restart unicorn with USR2"
  task restart: :environment do
    unicorn_signal :USR2
  end

  desc "Increment number of worker processes"
  task increment: :environment do
    unicorn_signal :TTIN
  end

  desc "Decrement number of worker processes"
  task decrement: :environment do
    unicorn_signal :TTOU
  end

  def unicorn_signal signal
    Process.kill signal, unicorn_pid
  end

  def unicorn_pid
    begin
      File.read("#{Rails.root}/tmp/pids/unicorn.pid").to_i
    rescue Errno::ENOENT
      raise "Unicorn doesn't seem to be running"
    end
  end
end
