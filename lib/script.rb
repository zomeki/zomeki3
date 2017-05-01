class Script
  cattr_reader :site
  cattr_reader :options

  def self.run_from_web(path, options = {})
    unless proc = Sys::Process.lock(name: path, site_id: options[:site_id], options: options.except(:site_id), lock_by: :site)
      raise "プロセスが既に実行されています。"
    end

    ruby   = "#{RbConfig::CONFIG["bindir"]}/ruby"
    runner = "#{Rails.root}/bin/rails runner"
    opts   = options.merge(process_id: proc.id).inspect
    cmd    = "#{ruby} #{runner} -e #{Rails.env} \"Script.run('#{path}', #{opts})\""
    system("#{cmd} >/dev/null &")
    return true
  end

  def self.run(path, options = {})
    @@kill     = options.delete(:kill) || 3.hours.to_i
    @@path     = path
    @@proc     = nil
    @@time     = nil
    @@success  = 0
    @@reflesh  = 10
    @@site     = Cms::Site.find_by(id: options.delete(:site_id))
    @@lock_by  = options.delete(:lock_by)
    @@options  = options

    ENV['INPUTRC'] ||= '/etc/inputrc'

    self.start_process do
      ## start
      start = Time.now
      self.log "[#{start.strftime('%Y-%m-%d %H:%M:%S')}] script:#{@@path} ... start"

      ## dispatch
      uri = URI.parse(path)
      script = "#{File.dirname(uri.path).camelize}Script".constantize
      method = File.basename(uri.path)
      script.new(@@options).public_send(method)
      self.log "success #{@@proc.success_per_total}"

      ## finish
      finish = Time.now
      past   = sprintf('%.2f', finish - start)
      self.log "[#{finish.strftime('%Y-%m-%d %H:%M:%S')}] script:#{@@path} ... finished (#{past} sec)"
    end
  end

  def self.total(num = 1)
    return unless defined? @@proc
    return unless @@proc
    if num.is_a?(Fixnum)
      @@proc.total += num
    else
      @@proc.total = nil
    end
    if num != 1
      @@proc.updated_at = DateTime.now
      @@proc.save
    end
    return @@proc.total
  end

  def self.current(num = 1)
    return unless defined? @@proc
    return unless @@proc
    if (@@proc.current % @@reflesh) == 0
      value = @@proc.interrupted?
      raise InterruptException.new(value) if value == "stop"
    end
    if @@proc.started_at.to_i + @@kill < Time.now.to_i
      @@proc.update_attributes(interrupt: 'timeout') 
      raise InterruptException.new("timeout.")
    end
    @@proc.current += num
    if @@proc.current >= @@proc.current_was + 100
      @@proc.save
    end
    return @@proc.current
  end

  def self.success(num = 1)
    return unless defined? @@proc
    return unless @@proc
    @@proc.success += num
    if num > 0 && (@@proc.success % @@reflesh) == 0
      @@proc.updated_at = DateTime.now
      @@proc.save
    end
    return @@proc.success
  end

  def self.error(message = nil)
    return unless defined? @@proc
    return unless @@proc
    if message
      @@proc.error += 1
      self.log "Error: #{message}"
    end
    return @@proc.error
  end

  def self.log(message)
    return unless defined? @@proc
    return unless @@proc
    if message.present?
      @@proc.message = "#{@@proc.message}#{message}\n"
      puts message
    end
    return message
  end

  def self.progress(item)
    self.current
    yield
    self.success
  rescue ::Script::InterruptException => e
    raise e
  rescue => e
    self.error "#{item.class}##{item.id}: #{e}"
    error_log e
    error_log e.backtrace.join("\n")
  end

  protected

  def self.start_process
    if self.lock
      yield
    else
      puts "already running"
      return "already running"
    end
  rescue ::Script::InterruptException => e
    self.log e
  rescue => e
    self.log e
    self.log e.backtrace.slice(0, 20).join("\n")
    error_log e
    error_log e.backtrace.join("\n")
  ensure
    self.unlock
  end

  def self.lock
    @@proc =
      if @@options[:process_id]
        Sys::Process.find_by(id: @@options[:process_id])
      else
        Sys::Process.lock(name: @@path, site_id: @@site.try(:id), options: @@options, time_limit: @@kill, lock_by: @@lock_by)
      end
    @@time = @@proc.created_at if @@proc
    @@proc
  end

  def self.unlock
    @@proc.unlock if @@proc && @@proc.closed_at.nil?
  end

  class InterruptException < StandardError
    ## interrupt by admin
  end
end

