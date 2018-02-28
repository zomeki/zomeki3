class Cms::TalkTask < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site

  belongs_to :talk_processable, polymorphic: true
  has_one :publisher, primary_key: :path, foreign_key: :path, class_name: 'Sys::Publisher'

  define_model_callbacks :publish_files, :close_files
  after_publish_files Cms::FileTransferCallbacks.new(:path)
  after_close_files Cms::FileTransferCallbacks.new(:path)

  validates :path, presence: true

  def exec
    publish_talk_file
  end

  private

  def public_talk_file_path
    "#{path}.mp3"
  end

  def publish_talk_file
    return false unless ::File.exist?(path)
    return false if talk_processable.nil? || publisher.nil?

    jtalk = Cms::Lib::Navi::Jtalk.new
    jtalk.make(::File.read(path), site_id: site_id)
    mp3 = jtalk.output
    return false unless mp3
    return false if ::File.stat(mp3[:path]).size == 0

    run_callbacks :publish_files do
      dep = [publisher.dependent.presence, "talk"].compact.join('/')
      pub = Sys::Publisher.where(publishable: talk_processable, dependent: dep).first_or_initialize
      pub.publish_file_with_digest(mp3[:path], public_talk_file_path)
      ::File.chmod(0644, public_talk_file_path)
    end

    ::File.delete(mp3[:path]) if ::File.exist?(mp3[:path])
    return true
  end

  def close_talk_file
    return false unless ::File.exist?(public_talk_file_path)

    run_callbacks :close_files do
      ::File.delete(public_talk_file_path)
    end
    return true
  end
end
