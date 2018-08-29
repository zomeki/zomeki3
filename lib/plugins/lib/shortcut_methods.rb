def debug_log(message)
  Timecop.return do
    Rails.logger.debug build_log_message(message.pretty_inspect, "DEBUG")
  end
end

def info_log(message)
  Timecop.return do
    Rails.logger.info build_log_message(message, "INFO")
  end
end

def warn_log(message)
  Timecop.return do
    Rails.logger.warn build_log_message(message, "WARN")
  end
end

def error_log(message)
  Timecop.return do
    Rails.logger.error build_log_message(message, "ERROR")
  end
end

def build_log_message(message, level)
  log = if Rails.env.development?
          "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{level} #{message}"
        else
          message.to_s
        end
  log = "#{log}: #{message.backtrace.join("\n")}" if message.is_a?(Exception) && message.backtrace.present?
  log
end

class String
  def to_utf8
    require "nkf"
    NKF.nkf('-wxm0', self.to_s)
  end
end
