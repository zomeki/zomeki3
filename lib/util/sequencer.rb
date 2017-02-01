require 'digest/md5'

class Util::Sequencer
  def self.next_id(name, options = {})
    name    = name.to_s
    version = options[:version].to_i
    site_id = options[:site_id]

    lock = Util::File::Lock.lock("#{name}_#{version}_#{site_id}")
    raise 'error: sequencer locked' unless lock

    seq = Sys::Sequence.next(name, version, site_id)

    lock.unlock

    if options[:md5]
      Digest::MD5.new.update(seq.value.to_s)
    else
      seq.value
    end
  end
end
