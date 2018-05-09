class Util::Tika
  class << self
    def get_text(path)
      require 'tika-client'
      client = Tika::Client.new(host: 'localhost', port: 9998)
      client.get_text(file: File.new(path), content_type: 'application/octet-stream').force_encoding('utf-8')
    rescue => e
      warn_log e
      nil
    end
  end
end
