class ApplicationRecordSlave < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def slave_configs
      Rails.configuration.database_configuration.select { |sec| sec.to_s =~ /^#{Rails.env}_pull_database/ }
    end

    def each_slaves
      slave_configs.each do |sec, slave|
        begin
          self.establish_connection(slave).connection
        rescue => e
          error_log e
          next
        end
        yield self
      end
    end
  end
end
