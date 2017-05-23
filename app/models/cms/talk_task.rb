class Cms::TalkTask < ApplicationRecord
  include Sys::Model::Base

  define_model_callbacks :publish_files, :close_files
  after_publish_files FileTransferCallbacks.new(:path)
  after_close_files FileTransferCallbacks.new(:path)

  validates :path, presence: true

  def exec
    if Zomeki.config.application['sys.clean_statics']
      close_file
    else
      publish_file
    end
  end

  private

  def publish_file
    return false unless ::File.exist?(path)

    mp3 = self.class.make_mp3(::File.read(path), site_id)
    return false unless mp3
    return false if ::File.stat(mp3[:path]).size == 0

    run_callbacks :publish_files do
      FileUtils.mv(mp3[:path], "#{path}.mp3")
      ::File.chmod(0644, "#{path}.mp3")
    end
  end

  def close_file
    return false unless ::File.exist?("#{path}.mp3")

    run_callbacks :close_files do
      ::File.delete("#{path}.mp3")
    end
    return true
  end

  class << self
    def make_mp3(body, site_id)
      jtalk = Cms::Lib::Navi::Jtalk.new
      jtalk.make(body, site_id: site_id)
      jtalk.output
    end
  end
end
